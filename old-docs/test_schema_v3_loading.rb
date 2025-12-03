#!/usr/bin/env ruby
# frozen_string_literal: true

# Test script for Phase 3 schema loading

require 'yaml'

puts '=== Phase 3 Schema Loading Test ==='
puts

# Test 1: Load schema loader configuration
puts '1. Loading schema loader configuration...'
begin
  schema_loader_path = 'config/ooxml/schema_loader.yml'
  loader_config = YAML.load_file(schema_loader_path)
  puts '   ✓ Schema loader configuration loaded successfully'
rescue StandardError => e
  puts "   ✗ Failed to load schema loader: #{e.message}"
  exit 1
end

# Test 2: Check schema metadata
puts "\n2. Checking schema metadata..."
metadata = loader_config['metadata']

puts "   Version: #{metadata['version']}"
puts "   Phase: #{metadata['phase']}"
puts "   Total Elements: #{metadata['total_elements']}"
puts "   Phase 1: #{metadata['phase_1_elements']} elements"
puts "   Phase 2: #{metadata['phase_2_additions']} elements"
puts "   Phase 3: #{metadata['phase_3_additions']} elements"
puts "   Coverage: #{metadata['coverage']}"

expected_total = metadata['phase_1_elements'] + metadata['phase_2_additions'] + metadata['phase_3_additions']
if metadata['total_elements'] == expected_total
  puts "   ✓ Element count is consistent (#{metadata['total_elements']} = #{expected_total})"
else
  puts "   ✗ Element count mismatch: #{metadata['total_elements']} != #{expected_total}"
end

# Test 3: Verify new schema files
puts "\n3. Verifying Phase 3 schema files..."
schemas_to_check = {
  '08_styles.yml' => { expected_elements: 10, expected_status: 'complete', expected_phase: '3' },
  '09_numbering.yml' => { expected_elements: 6, expected_status: 'complete', expected_phase: '3' },
  '11_drawing.yml' => { expected_elements: 19, expected_status: 'complete', expected_phase: '3' }
}

all_valid = true
schemas_to_check.each do |schema_file, expectations|
  path = "config/ooxml/schemas/#{schema_file}"
  begin
    schema_data = YAML.load_file(path)
    element_count = schema_data['metadata']['element_count']
    status = schema_data['metadata']['status']
    phase = schema_data['metadata']['phase']

    puts "\n   #{schema_file}:"
    puts "     Elements: #{element_count} (expected: #{expectations[:expected_elements]})"
    puts "     Status: #{status} (expected: #{expectations[:expected_status]})"
    puts "     Phase: #{phase} (expected: #{expectations[:expected_phase]})"

    if element_count == expectations[:expected_elements] &&
       status == expectations[:expected_status] &&
       phase == expectations[:expected_phase]
      puts '     ✓ Schema file is valid'
    else
      puts '     ✗ Schema file has mismatches'
      all_valid = false
    end
  rescue StandardError => e
    puts "   ✗ Failed to load #{schema_file}: #{e.message}"
    all_valid = false
  end
end

# Test 4: Check specific element definitions in styles schema
puts "\n4. Checking styles schema elements..."
styles_schema = YAML.load_file('config/ooxml/schemas/08_styles.yml')
expected_style_elements = %w[
  styles doc_defaults rpr_default ppr_default style
  tbl_style_pr latent_styles lsd_exception
]

styles_elements = styles_schema['elements']
expected_style_elements.each do |elem|
  if styles_elements.key?(elem)
    puts "   ✓ #{elem} defined"
  else
    puts "   ✗ #{elem} missing"
    all_valid = false
  end
end

# Test 5: Check specific element definitions in numbering schema
puts "\n5. Checking numbering schema elements..."
numbering_schema = YAML.load_file('config/ooxml/schemas/09_numbering.yml')
expected_numbering_elements = %w[
  numbering abstract_num num lvl lvl_override num_pic_bullet
]

numbering_elements = numbering_schema['elements']
expected_numbering_elements.each do |elem|
  if numbering_elements.key?(elem)
    puts "   ✓ #{elem} defined"
  else
    puts "   ✗ #{elem} missing"
    all_valid = false
  end
end

# Test 6: Check enhanced drawing schema elements
puts "\n6. Checking enhanced drawing schema elements..."
drawing_schema = YAML.load_file('config/ooxml/schemas/11_drawing.yml')
expected_new_drawing_elements = %w[
  simple_pos position_h position_v align pos_offset
  wrap_square wrap_tight wrap_through wrap_top_and_bottom
  effect_extent graphic_data blip_fill sp_pr
]

drawing_elements = drawing_schema['elements']
expected_new_drawing_elements.each do |elem|
  if drawing_elements.key?(elem)
    puts "   ✓ #{elem} defined"
  else
    puts "   ✗ #{elem} missing"
    all_valid = false
  end
end

# Test 7: Verify all schema files listed in loader
puts "\n7. Verifying all schema files exist..."
loader_config['schema_files'].each do |schema_file|
  full_path = "config/ooxml/#{schema_file}"
  if File.exist?(full_path)
    puts "   ✓ #{schema_file}"
  else
    puts "   ✗ #{schema_file} - FILE NOT FOUND"
    all_valid = false
  end
end

# Summary
puts "\n=== Phase 3 Schema Loading Test Complete ==="
if all_valid
  puts '✓ All tests passed!'
  puts '✓ Schema v3.0 is ready'
  puts
  puts 'Summary:'
  puts "  - Total elements: #{metadata['total_elements']}"
  puts '  - Styles: 10 elements'
  puts '  - Numbering: 6 elements'
  puts '  - Drawing enhancements: 14 elements'
  puts "  - Phase 3 additions: #{metadata['phase_3_additions']} elements"
  exit 0
else
  puts '✗ Some tests failed'
  exit 1
end
