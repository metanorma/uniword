# frozen_string_literal: true

# 05: Cache Attribute#default per register
#
# Problem:
#   Attribute#default (attribute.rb:309-311) is called 1.07M times during
#   ISO 690 deserialization. Each call:
#     1. Calls default_value(register, instance_object) -- checks options hash, may call proc
#     2. Calls cast_value(result, register) -- does type resolution + cast
#
#   The result for a given (attr, register) is deterministic (when instance_object
#   is nil) -- the default value doesn't change. Yet it's recomputed every time
#   an element doesn't have a value for this attribute.
#
# Reproduction:
#   This benchmark measures the overhead of repeated default computations.

require "bundler/setup"
require "lutaml/model"
require "benchmark"

# --- Model where most elements use defaults ---
class DefaultItem < Lutaml::Model::Serializable
  attribute :name, :string
  attribute :type, :string, default: -> { "default_type" }
  attribute :status, :string, default: -> { "active" }
  attribute :version, :string, default: -> { "1.0" }
  attribute :priority, :string, default: -> { "normal" }

  xml do
    root "default_item"
    map_element "name", to: :name
    map_element "type", to: :type
    map_element "status", to: :status
    map_element "version", to: :version
    map_element "priority", to: :priority
  end
end

class DefaultContainer < Lutaml::Model::Serializable
  attribute :items, DefaultItem, collection: true

  xml do
    root "container"
    map_element "default_item", to: :items
  end
end

# Generate XML where most attributes use defaults (only name is set)
items = (1..1000).map do |i|
  "<default_item><name>item_#{i}</name></default_item>"
end.join
xml = "<container>#{items}</container>"

times = Benchmark.measure do
  100.times { DefaultContainer.from_xml(xml) }
end

puts "Current: Deserialize 1000 elements (4 defaults each) x 100 iterations"
puts times.format("  %t total, %r real")
puts

# --- Count default() calls using prepend ---
default_calls = 0

counter_module = Module.new do
  define_method(:default) do |*args|
    default_calls += 1
    super(*args)
  end
end
Lutaml::Model::Attribute.prepend(counter_module)

DefaultContainer.from_xml(xml)
puts "Attribute#default calls for 1 deserialization of 1000 elements: #{default_calls}"
puts "  That's #{(default_calls.to_f / 1000).round(1)} calls per element"
puts "  Each with proc invocation + cast_value for a deterministic result"
puts

# --- Suggested implementation ---
# In lib/lutaml/model/attribute.rb, around line 309:
#
#   def default(register = Lutaml::Model::Config.default_register,
#               instance_object = nil)
#     register_key = register || :default
#
#     # Only cache when instance_object is nil (common case during deserialization).
#     # When instance_object is provided, the proc may depend on instance state.
#     if instance_object.nil?
#       cache_key = register_key
#       @default_cache ||= {}
#       cached = @default_cache[cache_key]
#       return cached if cached
#
#       result = cast_value(default_value(register_key, nil), register_key)
#       @default_cache[cache_key] = result
#       result
#     else
#       cast_value(default_value(register_key, instance_object), register_key)
#     end
#   end
#
# Safety: Attribute objects are shared across instances but the default for a
# given register is immutable. The cache is per-Attribute (not per-instance),
# so all instances benefit.
#
# Note: If any default proc is stateful (depends on time, random, etc.),
# the cache would return stale values. But OOXML defaults are all static strings
# and integers, so this is safe in practice.

puts "Suggested change in lib/lutaml/model/attribute.rb:309:"
puts "  Cache default(register) when instance_object is nil"
puts "  @default_cache ||= {}; @default_cache[register_key] = result"
puts "  Estimated savings: ~1.5s on ISO 690 document"
