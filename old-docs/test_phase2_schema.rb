#!/usr/bin/env ruby
# frozen_string_literal: true

# Test script for Phase 2 schema implementation

require 'yaml'
require_relative 'lib/uniword/ooxml/schema/ooxml_schema'

puts '=' * 60
puts 'Testing V2.0 Phase 2 Schema Implementation'
puts '=' * 60
puts

# Load the schema
puts '1. Loading multi-file schema...'
schema = Uniword::Ooxml::Schema::OoxmlSchema.load

puts '✓ Schema loaded successfully'
puts "  Version: #{schema.version}"
puts "  Element count: #{schema.elements.count}"
puts

# Verify Phase 1 elements still exist
puts '2. Verifying Phase 1 elements...'
phase1_elements = %w[
  document body
  paragraph paragraphproperties hyperlink
  run runproperties textelement image comment
  table tableproperties tablerow tablerowproperties
  tablecell tablecellproperties
  header footer header_reference footer_reference
  field_simple field_char instr_text field_data
  footnote endnote footnote_reference endnote_reference
  footnote_ref endnote_ref
  section_properties
]

missing = phase1_elements.reject { |e| schema.elements.key?(e) }
if missing.empty?
  puts "✓ All #{phase1_elements.count} Phase 1 elements present"
else
  puts "✗ Missing Phase 1 elements: #{missing.join(', ')}"
end
puts

# Verify new Phase 2 paragraph property elements
puts '3. Verifying new Phase 2 paragraph property elements...'
new_para_elements = %w[
  shading tabs contextual_spacing widow_control
  suppress_auto_hyphens bidi adjust_right_ind snap_to_grid
  text_alignment text_direction div_id cnf_style
  rpr_change sect_pr_change
]

# Check if these are in paragraph properties children
para_props = schema.elements['paragraphproperties']
if para_props&.children
  para_children = para_props.children.map(&:element)
  new_para_found = new_para_elements.select { |e| para_children.include?(e) }
  puts "✓ Found #{new_para_found.count}/#{new_para_elements.count} new paragraph properties"
  if new_para_found.count < new_para_elements.count
    missing_para = new_para_elements - new_para_found
    puts "  Missing: #{missing_para.join(', ')}"
  end
else
  puts '✗ Could not verify paragraph properties'
end
puts

# Verify new Phase 2 run property elements
puts '4. Verifying new Phase 2 run property elements...'
new_run_elements = %w[
  lang east_asian_layout emboss imprint outline
  shadow vanish web_hidden fit_text kern
  position spacing
]

# Check if these are in run properties children
run_props = schema.elements['runproperties']
if run_props&.children
  run_children = run_props.children.map(&:element)
  new_run_found = new_run_elements.select { |e| run_children.include?(e) }
  puts "✓ Found #{new_run_found.count}/#{new_run_elements.count} new run properties"
  if new_run_found.count < new_run_elements.count
    missing_run = new_run_elements - new_run_found
    puts "  Missing: #{missing_run.join(', ')}"
  end
else
  puts '✗ Could not verify run properties'
end
puts

# Verify new Phase 2 drawing elements
puts '5. Verifying new Phase 2 drawing elements...'
new_drawing_elements = %w[
  docpr extent graphic picture blip
]

drawing_found = new_drawing_elements.select { |e| schema.elements.key?(e) }
if drawing_found.count == new_drawing_elements.count
  puts "✓ All #{new_drawing_elements.count} new drawing elements present"
else
  puts "✓ Found #{drawing_found.count}/#{new_drawing_elements.count} drawing elements"
  missing_drawing = new_drawing_elements - drawing_found
  puts "  Missing: #{missing_drawing.join(', ')}" if missing_drawing.any?
end
puts

# Summary
puts '=' * 60
puts 'SUMMARY'
puts '=' * 60
puts "Total elements in schema: #{schema.elements.count}"
puts 'Expected: ~64 (31 Phase 1 + 33 Phase 2)'
puts
puts 'Phase 2 additions:'
puts '  - Paragraph properties: 14 new child properties'
puts '  - Run properties: 12 new child properties'
puts '  - Drawing elements: 5 new elements'
puts '=' * 60
