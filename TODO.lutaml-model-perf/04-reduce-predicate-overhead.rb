# frozen_string_literal: true

# 04: Reduce predicate call overhead (is_a?, nil?, !)
#
# Problem:
#   Combined predicate overhead in model_transform.rb hot paths:
#     Kernel#is_a?: 37.2M calls, 5.6s self
#     Kernel#nil?: 30.7M calls, 4.2s self
#     BasicObject#!: 35.8M calls, 4.7s self
#   Total: 103.7M predicate calls for 148,955 elements (697 per element).
#
#   Key hotspot: instance.is_a?(::Lutaml::Model::Serialize) checked at
#   model_transform.rb:184, 417 inside loops that run per-element and per-rule.
#
# Reproduction:
#   Counts is_a?(Serialize) calls during deserialization.

require "bundler/setup"
require "lutaml/model"
require "benchmark"

# --- Nested model to exercise the hot path ---
class Inner < Lutaml::Model::Serializable
  attribute :val, :string
  xml do
    root "inner"
    map_element "val", to: :val
  end
end

class Outer < Lutaml::Model::Serializable
  attribute :title, :string
  attribute :items, Inner, collection: true

  xml do
    root "outer"
    map_element "title", to: :title
    map_element "inner", to: :items
  end
end

# Generate deeply nested XML
items = (1..200).map { |i| "<inner><val>v#{i}</val></inner>" }.join
xml = "<outer><title>test</title>#{items}</outer>"

times = Benchmark.measure do
  200.times { Outer.from_xml(xml) }
end

puts "Current: Deserialize 201 elements x 200 iterations"
puts times.format("  %t total, %r real")
puts

# --- Count is_a? calls ---
isa_count = 0
orig_is_a = Object.instance_method(:is_a?)

Object.class_eval do
  define_method(:is_a?) do |mod|
    isa_count += 1
    orig_is_a.bind_call(self, mod)
  end
end

Outer.from_xml(xml)
puts "is_a? calls (all types) for 1 deserialization of 201 elements: #{isa_count}"
puts "  That's #{(isa_count.to_f / 201).round(1)} is_a? calls per element"
puts

# Restore
Object.class_eval do
  define_method(:is_a?, orig_is_a)
end

# --- Suggested implementation ---
# 1. In model_transform.rb:data_to_model (line 26-31), set a flag:
#      instance.instance_variable_set(:@_is_serialize, true)
#    Then in value_for_rule (line 417), replace:
#      instance.is_a?(::Lutaml::Model::Serialize)
#    with:
#      instance.instance_variable_defined?(:@_is_serialize)
#    ivar_defined? is a C-level hash lookup, no method dispatch.
#
# 2. In apply_xml_mapping (line 184), replace:
#      instance.is_a?(::Lutaml::Model::Serialize)
#    with:
#      instance.respond_to?(:lutaml_register)
#    respond_to? is cheaper than is_a? for single-module checks.
#
# 3. In the children loop (lines 591, 606, 620, 670), cache child type:
#      child_is_xml = child.is_a?(::Lutaml::Xml::XmlElement)
#    before the per-child block, since all children of an element are
#    typically the same type.

puts "Suggested changes in lib/lutaml/xml/model_transform.rb:"
puts "  1. Set @_is_serialize flag at allocation, check with ivar_defined?"
puts "  2. Cache child.is_a?(XmlElement) once before children loop"
puts "  3. Replace is_a? with respond_to? where possible"
puts "  Estimated savings: ~2s on ISO 690 document"
