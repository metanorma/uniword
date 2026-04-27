# frozen_string_literal: true

# 03: Reduce mappings_for call count
#
# Problem:
#   `mappings_for(:xml)` is called at multiple points per element:
#     model_transform.rb:194  -- resolve mappings for element
#     model_transform.rb:215  -- resolve xml_mapping for ordering
#     model_transform.rb:303  -- resolve xml_mapping (fallback in set_instance_ordering)
#     model_transform.rb:523  -- per-rule: resolve model mapping for alias matching
#     model_transform.rb:624  -- per-child: resolve child mapping for namespace alias
#
#   Each call goes through TransformationRegistry with Array key lookup.
#   Total: 2.73M calls for 148K elements (~18 calls per element).
#
# Reproduction:
#   Monkey-patches mappings_for to count calls during deserialization.

require "bundler/setup"
require "lutaml/model"
require "benchmark"

# --- Model with nested elements ---
class ChildEl < Lutaml::Model::Serializable
  attribute :text, :string
  xml do
    root "child"
    map_element "text", to: :text
  end
end

class ParentEl < Lutaml::Model::Serializable
  attribute :name, :string
  attribute :children, ChildEl, collection: true

  xml do
    root "parent"
    map_element "name", to: :name
    map_element "child", to: :children
  end
end

class RootEl < Lutaml::Model::Serializable
  attribute :name, :string
  attribute :parents, ParentEl, collection: true

  xml do
    root "root"
    map_element "name", to: :name
    map_element "parent", to: :parents
  end
end

# Generate 500 parents with 5 children each
children_xml = (1..5).map { |j| "<child><text>t#{j}</text></child>" }.join
parents_xml = (1..500).map do |i|
  "<parent><name>p#{i}</name>#{children_xml}</parent>"
end.join
xml = "<root><name>root</name>#{parents_xml}</root>"

times = Benchmark.measure do
  50.times { RootEl.from_xml(xml) }
end

puts "Current: Deserialize 500 parents (5 children each) x 50 iterations"
puts times.format("  %t total, %r real")
puts

# --- Count mappings_for calls ---
call_count = 0

orig_mf = Lutaml::Model::Serialize::FormatConversion.instance_method(:mappings_for)
Lutaml::Model::Serialize::FormatConversion.class_eval do
  define_method(:mappings_for) do |*args, &blk|
    call_count += 1
    orig_mf.bind_call(self, *args, &blk)
  end
end

RootEl.from_xml(xml)
total_elements = 1 + 500 + (500 * 5) # root + 500 parents + 2500 children
puts "mappings_for calls for 1 deserialization of #{total_elements} elements: #{call_count}"
puts "  That's #{(call_count.to_f / total_elements).round(1)} calls per element"
puts "  If cached once per element, could reduce to ~1 call per element"
puts

# --- Suggested implementation ---
# In lib/lutaml/xml/model_transform.rb, apply_xml_mapping method:
#
#   # Current (2 separate calls):
#   mappings = options[:mappings] || mappings_for(:xml, register).mappings(register)  # :194
#   xml_mapping = mappings_for(:xml)  # :215
#
#   # Proposed (1 call, reuse result):
#   xml_mapping = mappings_for(:xml, effective_register)
#   mappings = options[:mappings] || xml_mapping.mappings(effective_register)
#
#   # Also fix set_instance_ordering (line 303):
#   # Current: xml_mapping ||= mappings_for(:xml)
#   # Proposed: pass xml_mapping as parameter (already partially done)
#
#   # For resolve_rule_names_with_type (line 523, 786):
#   # Cache attr_type.mappings_for(:xml) on the Attribute object.
#   # The result is deterministic per (attr, register) and the Attribute
#   # object is long-lived.

puts "Suggested change in lib/lutaml/xml/model_transform.rb:"
puts "  1. Cache xml_mapping = mappings_for(:xml) once in apply_xml_mapping"
puts "  2. Reuse xml_mapping instead of calling mappings_for(:xml) again at :215"
puts "  3. Pass xml_mapping as parameter to sub-methods"
puts "  4. Cache attr_type's xml_mapping on Attribute per register"
puts "  Estimated savings: ~1.5s on ISO 690 document"
