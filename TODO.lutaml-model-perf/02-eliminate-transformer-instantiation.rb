# frozen_string_literal: true

# 02: Eliminate Transformer object instantiation
#
# Problem:
#   Lutaml::Model::Transformer.call (services/transformer.rb:5-7) creates a
#   new instance via `new(rule, attribute, format).call(value)` every time.
#   Called 2.75M times during ISO 690 deserialization.
#
#   Each instance is used once and discarded -- pure allocation overhead.
#   The fast path (no transforms) is already handled by mapping_rule.rb:314-316,
#   but for rules WITH transforms, an instance is still created each time.
#
# Reproduction:
#   Measures object allocation overhead from Transformer.new calls.

require "bundler/setup"
require "lutaml/model"
require "benchmark"

# --- Model with a transform ---
class UpcaseElement < Lutaml::Model::Serializable
  attribute :name, :string

  xml do
    root "upcase"
    map_element "name", to: :name, transform: { import: lambda(&:upcase) }
  end
end

class UpcaseRoot < Lutaml::Model::Serializable
  attribute :children, UpcaseElement, collection: true

  xml do
    root "root"
    map_element "upcase", to: :children
  end
end

# Generate XML with 1000 elements, each having a transform
children = (1..1000).map { |i| "<upcase><name>value#{i}</name></upcase>" }.join
xml = "<root>#{children}</root>"

times = Benchmark.measure do
  100.times { UpcaseRoot.from_xml(xml) }
end

puts "Current: Deserialize 1000 elements with transform x 100 iterations"
puts times.format("  %t total, %r real")
puts

# --- Count Transformer.new calls ---
# Each Transformer.call does new(...).call(value), so counting .new is equivalent.
transformer_calls = 0

Lutaml::Model::Transformer.define_singleton_method(:new) do |*args|
  transformer_calls += 1
  super(*args)
end

UpcaseRoot.from_xml(xml)
puts "Transformer.new calls for 1 deserialization of 1000 elements: #{transformer_calls}"
puts "  Each call creates a new Transformer/ImportTransformer instance"
puts "  That's #{(transformer_calls.to_f / 1000).round(1)} allocations per element"
puts

# --- Suggested implementation ---
# In lib/lutaml/model/services/transformer.rb:
#
#   class ImportTransformer < Transformer
#     class << self
#       # Module-level call that avoids instantiation
#       def call(value, rule, attribute, format: nil)
#         methods = transformation_methods_static(rule, attribute)
#         return value if methods.empty?
#         methods.reduce(value) { |v, m| m.call(v) }
#       end
#
#       private
#
#       def transformation_methods_static(rule, attribute)
#         [
#           get_transform_static(rule, :import),
#           get_transform_static(attribute, :import),
#         ].compact
#       end
#
#       def get_transform_static(obj, direction)
#         transform = obj&.transform
#         return nil if transform.nil? || transform.is_a?(Class)
#         transform.is_a?(::Hash) ? transform[direction] : transform
#       end
#     end
#   end
#
# This eliminates the `new` allocation entirely. The transformation_methods
# result is just an array of 0-2 lambdas/procs, computable without instance state.

puts "Suggested change in lib/lutaml/model/services/transformer.rb:"
puts "  Make ImportTransformer.call a class method that computes transforms"
puts "  directly without creating an instance."
puts "  Estimated savings: ~2s on ISO 690 document"
