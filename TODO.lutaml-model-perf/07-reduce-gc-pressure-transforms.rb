# frozen_string_literal: true

# 07: Reduce GC pressure from Transform allocations
#
# Problem:
#   22.9% of execution time is GC (5022 stackprof samples: 3606 marking +
#   1416 sweeping). The primary cause is 148,955 Transform.new allocations.
#
#   Each Transform.new (transform.rb:17-21):
#     1. Allocates a new Transform object
#     2. Computes @attributes = context.attributes(register) -- hash lookup
#     3. Stores @context and @lutaml_register
#
#   The @attributes hash is IDENTICAL for every element of the same model class
#   with the same register. Yet we allocate a new Transform for each.
#
# Reproduction:
#   This benchmark measures GC overhead from Transform allocations.

require "bundler/setup"
require "lutaml/model"
require "benchmark"

# --- Model with many instances (exercises Transform.new per element) ---
class SimpleItem < Lutaml::Model::Serializable
  attribute :id, :string
  attribute :value, :string

  xml do
    root "item"
    map_element "id", to: :id
    map_element "value", to: :value
  end
end

class Container < Lutaml::Model::Serializable
  attribute :items, SimpleItem, collection: true

  xml do
    root "container"
    map_element "item", to: :items
  end
end

# Generate 5000 items = 5000 Transform.new calls
xml = (1..5000).map do |i|
  "<item><id>#{i}</id><value>v#{i}</value></item>"
end.join
full_xml = "<container>#{xml}</container>"

# Warmup
Container.from_xml(full_xml)

# Benchmark with GC tracking
GC.start
gc_count_before = GC.count

times = Benchmark.measure do
  10.times { Container.from_xml(full_xml) }
end

gc_count_after = GC.count
puts "Current: Deserialize 5000 items x 10 iterations"
puts times.format("  %t total, %r real")
puts "GC collections: #{gc_count_after - gc_count_before}"
puts

# --- Count Transform allocations ---
transform_count = 0
Lutaml::Model::Transform.method(:new)

Lutaml::Model::Transform.define_singleton_method(:new) do |*args|
  transform_count += 1
  super(*args)
end

Container.from_xml(full_xml)
puts "Transform.new calls for 1 deserialization of 5000 items: #{transform_count}"
puts "  That's #{(transform_count.to_f / 5000).round(1)} Transform objects per item"
puts

# --- Suggested implementation ---
# Option A: Reuse a single Transform per (model_class, register)
#
# In lib/lutaml/model/transform.rb, add class-level cache:
#
#   class Transform
#     @transform_cache = {}
#     @transform_cache_mutex = Mutex.new
#
#     def self.data_to_model(context, data, format, options = {})
#       register = options[:register] || Config.default_register
#       cache_key = [context.object_id, register]
#
#       # Reuse cached Transform for same (context, register)
#       cached = @transform_cache[cache_key]
#       if cached
#         cached.data_to_model(data, format, options)
#       else
#         transform = new(context, register)
#         @transform_cache_mutex.synchronize { @transform_cache[cache_key] ||= transform }
#         transform.data_to_model(data, format, options)
#       end
#     end
#   end
#
#   Safety: Transform#data_to_model does not mutate @attributes or @context.
#   It reads @attributes to look up attribute definitions and @context for
#   model_class. These are read-only during deserialization.
#   Thread safety: The Mutex protects the cache write. Multiple threads
#   reading the same Transform is safe since it's read-only.
#
# Option B: Pass attributes as parameter instead of storing on instance
#
#   def self.data_to_model(context, data, format, options = {})
#     register = options[:register] || Config.default_register
#     attributes = context.attributes(register)
#     # Call data_to_model as a module method, passing attributes
#     _data_to_model(context, data, format, options, attributes)
#   end
#
# This eliminates 148K object allocations. Since GC takes 23% of runtime,
# reducing allocations by ~148K should cut GC time proportionally.

puts "Suggested change in lib/lutaml/model/transform.rb:"
puts "  Option A: Cache Transform per (context, register) -- reuse instance"
puts "  Option B: Pass attributes as parameter instead of storing on instance"
puts "  Both eliminate 148K Transform.new allocations"
puts "  Estimated savings: ~3s on ISO 690 document (from GC reduction)"
