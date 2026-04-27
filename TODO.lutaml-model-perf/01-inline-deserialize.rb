# frozen_string_literal: true

# 01: Inline deserialize for simple rules
#
# Problem:
#   MappingRule#deserialize (mapping/mapping_rule.rb:260-263) chains 3 methods:
#     handle_custom_method || handle_delegate || handle_transform_method
#   For 95%+ of rules, the first two return nil and handle_transform_method
#   runs the fast path (check + assign_value). That's 3 method dispatches
#   per rule when only 1 is needed.
#
#   For 1.38M rule evaluations, that's 4.14M method calls just to set an attribute.
#
# Reproduction:
#   This benchmark creates elements with many attributes and measures
#   deserialization time, then counts how many rules are "simple" vs "complex".

require "bundler/setup"
require "lutaml/model"
require "benchmark"

# --- Define a model similar to OOXML elements ---
class SimpleElement < Lutaml::Model::Serializable
  attribute :name, :string
  attribute :value, :string
  attribute :kind, :string
  attribute :id, :string
  attribute :css_class, :string
  attribute :style, :string
  attribute :lang, :string
  attribute :dir, :string
  attribute :tabindex, :string
  attribute :accesskey, :string

  xml do
    root "element"
    map_attribute "name", to: :name
    map_attribute "value", to: :value
    map_attribute "kind", to: :kind
    map_attribute "id", to: :id
    map_attribute "css_class", to: :css_class
    map_attribute "style", to: :style
    map_attribute "lang", to: :lang
    map_attribute "dir", to: :dir
    map_attribute "tabindex", to: :tabindex
    map_attribute "accesskey", to: :accesskey
  end
end

# Generate single XML document with many child elements
children = (1..1000).map do |i|
  %(<element name="n#{i}" value="v#{i}" kind="t#{i}" id="id#{i}" css_class="c#{i}" style="s#{i}" lang="en" dir="ltr" tabindex="#{i}" accesskey="k#{i}"/>)
end.join("\n")
single_xml = "<element name='root' value='root'>#{children}</element>"

# --- Benchmark current behavior ---
times = Benchmark.measure do
  100.times { SimpleElement.from_xml(single_xml) }
end

puts "Current: Deserialize 1 element with 1000 children (10 attrs each) x 100 iterations"
puts times.format("  %t total, %r real")
puts

# --- Demonstrate the overhead ---
# Count how many rules have custom methods vs simple
mappings = SimpleElement.mappings_for(:xml).mappings
total_rules = mappings.count
simple_rules = mappings.count do |r|
  !r.has_custom_method_for_deserialization? && !r.delegate
end
puts "Rules per element: #{total_rules} total, #{simple_rules} simple (#{(simple_rules.to_f / total_rules * 100).round(0)}%)"
puts "For 1001 elements x 10 rules = #{1001 * 10} total deserialize() calls"
puts "  #{1001 * simple_rules} are simple (could bypass 3-method chain)"
puts

# --- Count actual method dispatches inside deserialize ---
handle_custom_count = 0
handle_delegate_count = 0
handle_transform_count = 0

orig_deserialize = Lutaml::Model::MappingRule.instance_method(:deserialize)
Lutaml::Model::MappingRule.class_eval do
  define_method(:deserialize) do |*args|
    orig_deserialize.bind_call(self, *args)
  end
end

orig_custom = Lutaml::Model::MappingRule.instance_method(:handle_custom_method)
Lutaml::Model::MappingRule.class_eval do
  define_method(:handle_custom_method) do |*args|
    handle_custom_count += 1
    orig_custom.bind_call(self, *args)
  end
end

orig_delegate = Lutaml::Model::MappingRule.instance_method(:handle_delegate)
Lutaml::Model::MappingRule.class_eval do
  define_method(:handle_delegate) do |*args|
    handle_delegate_count += 1
    orig_delegate.bind_call(self, *args)
  end
end

orig_transform = Lutaml::Model::MappingRule.instance_method(:handle_transform_method)
Lutaml::Model::MappingRule.class_eval do
  define_method(:handle_transform_method) do |*args|
    handle_transform_count += 1
    orig_transform.bind_call(self, *args)
  end
end

SimpleElement.from_xml(single_xml)
puts "Method dispatch counts for 1 deserialization:"
puts "  handle_custom_method: #{handle_custom_count} calls (returns nil for #{simple_rules}/#{total_rules} rules)"
puts "  handle_delegate:      #{handle_delegate_count} calls (returns nil for all rules without delegate)"
puts "  handle_transform_method: #{handle_transform_count} calls (the actual work)"
puts "  Total dispatches: #{handle_custom_count + handle_delegate_count + handle_transform_count}"
puts "  Wasted dispatches: #{handle_custom_count + handle_delegate_count} (#{((handle_custom_count + handle_delegate_count).to_f / (handle_custom_count + handle_delegate_count + handle_transform_count) * 100).round(0)}%)"
puts

# --- Suggested implementation ---
# In lib/lutaml/model/mapping/mapping_rule.rb, after line 87 (@cached_castable):
#
#   # Cache whether this rule needs the full deserialize chain.
#   # All inputs are immutable after initialization.
#   @needs_full_deserialize = has_custom_method_for_deserialization? ||
#                              !!delegate
#
#   def needs_full_deserialize?
#     @needs_full_deserialize
#   end
#
# In lib/lutaml/xml/model_transform.rb, line 272:
#
#   # Current:
#   rule.deserialize(instance, value, attributes, context)
#
#   # Proposed:
#   if rule.needs_full_deserialize?
#     rule.deserialize(instance, value, attributes, context)
#   else
#     instance.public_send(:"#{rule.to}=", value)
#   end
#
# This eliminates 2 method dispatches per rule for the 95% simple case.

puts "Suggested change in lib/lutaml/model/mapping/mapping_rule.rb:"
puts "  Add @needs_full_deserialize = has_custom_method... || !!delegate at init"
puts "  Then in model_transform.rb:272, check flag before calling deserialize"
puts "  Estimated savings: ~3s on ISO 690 document"
