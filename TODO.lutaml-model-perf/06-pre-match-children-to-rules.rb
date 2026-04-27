# frozen_string_literal: true

# 06: Pre-match children to rules (skip 91% of value_for_rule calls)
#
# Problem:
#   In apply_xml_mapping (model_transform.rb:226-278), the mappings.each loop
#   calls value_for_rule for EVERY rule, even when no child element matches.
#
#   Profiled data from ISO 690:
#     - 1,393,987 rule evaluations
#     - 1,274,643 (91.4%) have NO matching child element
#     - Each non-matching call still executes: effective_register computation,
#       attribute_for_rule, resolve_rule_names_with_type, element_children access,
#       child_index lookup, and returns UninitializedClass
#
#   This wastes ~1.27M value_for_rule calls that could be skipped entirely.
#
# Reproduction:
#   This benchmark creates a model with many rules where most elements only
#   match 1-2 rules, simulating the ISO document pattern.

require "bundler/setup"
require "lutaml/model"
require "benchmark"

# --- Model with 10 rules but elements only match 1-2 ---
class ManyRules < Lutaml::Model::Serializable
  attribute :field_a, :string
  attribute :field_b, :string
  attribute :field_c, :string
  attribute :field_d, :string
  attribute :field_e, :string
  attribute :field_f, :string
  attribute :field_g, :string
  attribute :field_h, :string
  attribute :field_i, :string
  attribute :field_j, :string

  xml do
    root "many"
    map_element "field_a", to: :field_a
    map_element "field_b", to: :field_b
    map_element "field_c", to: :field_c
    map_element "field_d", to: :field_d
    map_element "field_e", to: :field_e
    map_element "field_f", to: :field_f
    map_element "field_g", to: :field_g
    map_element "field_h", to: :field_h
    map_element "field_i", to: :field_i
    map_element "field_j", to: :field_j
  end
end

class ManyRulesContainer < Lutaml::Model::Serializable
  attribute :items, ManyRules, collection: true

  xml do
    root "many_list"
    map_element "many", to: :items
  end
end

# Generate XML where each element only has 1-2 fields (simulating ISO pattern)
# 1000 elements x 10 rules = 10,000 rule evaluations, ~8,000 are no-match
items = (1..1000).map do |i|
  case i % 5
  when 0 then "<many><field_a>a</field_a></many>"
  when 1 then "<many><field_b>b</field_b><field_c>c</field_c></many>"
  when 2 then "<many><field_d>d</field_d></many>"
  when 3 then "<many><field_e>e</field_e><field_f>f</field_f></many>"
  when 4 then "<many><field_g>g</field_g></many>"
  end
end.join
xml = "<many_list>#{items}</many_list>"

times = Benchmark.measure do
  100.times { ManyRulesContainer.from_xml(xml) }
end

puts "Current: 1000 elements x 10 rules (most no-match) x 100 iterations"
puts times.format("  %t total, %r real")
puts

# --- Count no-match VFR calls using prepend ---
vfr_calls = 0
vfr_no_match = 0

counter = Module.new do
  define_method(:value_for_rule) do |*args, &blk|
    vfr_calls += 1
    result = super(*args, &blk)
    vfr_no_match += 1 if result == Lutaml::Model::UninitializedClass.instance
    result
  end
end
Lutaml::Xml::ModelTransform.prepend(counter)

ManyRulesContainer.from_xml(xml)
puts "value_for_rule calls: #{vfr_calls} total, #{vfr_no_match} no-match (#{(vfr_no_match.to_f / vfr_calls * 100).round(1)}%)"
puts

# --- Suggested implementation ---
# In lib/lutaml/xml/model_transform.rb, apply_xml_mapping method:
#
#   Before the mappings.each loop (around line 222), add:
#
#   # Pre-build a Set of child namespaced names for fast rule matching.
#   # This allows skipping 91% of value_for_rule calls.
#   child_names_set = nil
#   if doc.respond_to?(:element_children) && doc.element_children.any?
#     child_names_set = Set.new
#     doc.element_children.each do |child|
#       child_names_set.add(child.namespaced_name)
#       child_names_set.add(child.unprefixed_name)
#     end
#   end
#
#   Then inside the mappings.each loop, before calling value_for_rule:
#
#   # Skip rule if no child matches any of its possible names
#   if child_names_set && !rule.content_mapping? && !rule.raw_mapping? && !rule.attribute?
#     rule_names = rule.namespaced_names(default_namespace)
#     unless rule_names.any? { |rn| child_names_set.include?(rn) }
#       # No child matches -- assign default directly
#       if instance.using_default?(rule_to) || rule.render_default
#         defaults_used << rule_to
#         value = attr&.default(effective_register) || rule.to_value_for(instance)
#         rule.deserialize(instance, value, attributes, context)
#       end
#       next
#     end
#   end
#
# Note: Must handle multiple_mappings? (Array rule names) and
# content_mapping?/raw_mapping? rules that don't use child matching.

puts "Suggested change in lib/lutaml/xml/model_transform.rb:222:"
puts "  Pre-build Set of child namespaced names before mappings.each loop"
puts "  Skip value_for_rule when no child matches any rule name"
puts "  Must handle multiple_mappings? and content/raw mappings"
puts "  Estimated savings: ~2s on ISO 690 document"
