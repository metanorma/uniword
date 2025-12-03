#!/usr/bin/env ruby
# frozen_string_literal: true

# Test multi-file schema loader - standalone

require 'yaml'
require_relative 'lib/uniword/errors'
require_relative 'lib/uniword/configuration/configuration_loader'
require_relative 'lib/uniword/ooxml/schema/child_definition'
require_relative 'lib/uniword/ooxml/schema/attribute_definition'
require_relative 'lib/uniword/ooxml/schema/element_definition'
require_relative 'lib/uniword/ooxml/schema/ooxml_schema'

puts 'Testing Multi-File Schema Loader'
puts '=' * 60

# Test 1: Load multi-file schema
puts "\n1. Loading multi-file schema..."
begin
  schema = Uniword::Ooxml::Schema::OoxmlSchema.load
  puts '✓ Schema loaded successfully'
  puts "  Version: #{schema.version}"
  puts "  Element count: #{schema.element_count}"
  puts "  Elements: #{schema.element_names.sort.join(', ')}"
rescue StandardError => e
  puts "✗ Error loading schema: #{e.message}"
  puts e.backtrace.first(10)
  exit 1
end

# Test 2: Verify existing elements still work
puts "\n2. Verifying existing elements..."
existing_elements = %i[
  document body paragraph paragraphproperties
  run runproperties textelement table tableproperties
  tablerow tablecell hyperlink image comment
]

missing = []
existing_elements.each do |element|
  if schema.has_element?(element)
    puts "  ✓ #{element}"
  else
    puts "  ✗ #{element} - NOT FOUND"
    missing << element
  end
end

# Test 3: Verify new Phase 1 elements
puts "\n3. Verifying new Phase 1 elements..."
new_elements = %i[
  header footer header_reference footer_reference
  field_simple field_char instr_text field_data
  footnote endnote footnote_reference endnote_reference
  section_properties
]

new_elements.each do |element|
  if schema.has_element?(element)
    puts "  ✓ #{element}"
  else
    puts "  ✗ #{element} - NOT FOUND"
  end
end

# Test 4: Test element definition retrieval
puts "\n4. Testing element definition retrieval..."
begin
  para_def = schema.definition_for(:paragraph)
  puts "  ✓ Paragraph definition: #{para_def.tag}"
  puts "    Children: #{para_def.children.map(&:element_type).join(', ')}"
rescue StandardError => e
  puts "  ✗ Error: #{e.message}"
end

# Test 5: Legacy single-file loading (backward compatibility)
puts "\n5. Testing legacy single-file loading..."
begin
  legacy_schema = Uniword::Ooxml::Schema::OoxmlSchema.load('config/ooxml/schema_main.yml')
  puts "  ✓ Legacy schema loaded: #{legacy_schema.element_count} elements"
rescue StandardError => e
  puts "  ✗ Error: #{e.message}"
end

puts "\n#{'=' * 60}"
puts 'Schema Loader Test Complete'
puts "\nSummary:"
puts "  Total elements in multi-file schema: #{schema.element_count}"
puts "  Missing from existing: #{missing.join(', ')}" unless missing.empty?
puts '  Target: 37+ elements (37 existing + new Phase 1 elements)'

exit(missing.empty? ? 0 : 1)
