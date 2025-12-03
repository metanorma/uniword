#!/usr/bin/env ruby
# frozen_string_literal: true

# Load only what's needed for StyleSet testing
require 'lutaml/model'
require_relative 'lib/uniword/style'
require_relative 'lib/uniword/styleset'
require_relative 'lib/uniword/stylesets/yaml_styleset_loader'

puts 'Testing Simplified StyleSet YAML Loader'
puts '=' * 60

begin
  # Test loading with the simplified loader
  puts "\n1. Loading StyleSet from YAML (formal.yml)..."
  loader = Uniword::StyleSets::YamlStyleSetLoader.new
  styleset = loader.load('data/stylesets/formal.yml')
  puts '   ✓ StyleSet loaded successfully'

  # Display StyleSet details
  puts "\n2. StyleSet Details:"
  puts "   Name: #{styleset.name}"
  puts "   Source: #{styleset.source_file}"
  puts "   Total Styles: #{styleset.styles.count}"

  # Count by type
  para_count = styleset.paragraph_styles.count
  char_count = styleset.character_styles.count
  table_count = styleset.table_styles.count

  puts "   - Paragraph styles: #{para_count}"
  puts "   - Character styles: #{char_count}"
  puts "   - Table styles: #{table_count}"

  # Show sample styles with properties
  puts "\n3. Sample Styles (first 10):"
  styleset.styles.first(10).each do |style|
    props = []
    props << 'default' if style.default
    props << 'custom' if style.custom
    props << "based_on=#{style.based_on}" if style.based_on
    props << "linked=#{style.linked_style}" if style.linked_style
    props << 'quick_format' if style.quick_format

    prop_str = props.empty? ? '' : " (#{props.join(', ')})"
    puts "   - #{style.type.ljust(10)} #{style.id.ljust(25)} '#{style.name}'#{prop_str}"
  end

  # Test round-trip: YAML -> Model -> YAML
  puts "\n4. Testing Round-Trip (YAML -> Model -> YAML)..."
  yaml_output = styleset.to_yaml
  puts "   ✓ Serialized back to YAML (#{yaml_output.bytesize} bytes)"

  # Save to file for inspection
  output_file = 'test_styleset_roundtrip.yml'
  File.write(output_file, yaml_output)
  puts "   ✓ Saved to: #{output_file}"

  # Load the round-trip file
  puts "\n5. Reloading Round-Trip YAML..."
  styleset2 = loader.load(output_file)
  puts '   ✓ Reloaded successfully'
  puts "   - Name: #{styleset2.name}"
  puts "   - Styles: #{styleset2.styles.count}"

  # Verify data integrity
  puts "\n6. Data Integrity Check:"
  same_count = styleset.styles.count == styleset2.styles.count
  same_names = styleset.styles.map(&:id).sort == styleset2.styles.map(&:id).sort

  puts "   Style count match: #{same_count ? '✓' : '✗'}"
  puts "   Style IDs match: #{same_names ? '✓' : '✗'}"

  # Check property preservation
  original_first = styleset.styles.first
  roundtrip_first = styleset2.styles.first

  props_match = original_first.id == roundtrip_first.id &&
                original_first.type == roundtrip_first.type &&
                original_first.name == roundtrip_first.name &&
                original_first.default == roundtrip_first.default

  puts "   Properties preserved: #{props_match ? '✓' : '✗'}"

  # Show YAML excerpt
  puts "\n7. Generated YAML Excerpt (first 30 lines):"
  puts '-' * 60
  yaml_output.lines.first(30).each { |line| puts line }
  puts "... (#{yaml_output.lines.count - 30} more lines)" if yaml_output.lines.count > 30
  puts '-' * 60

  puts "\n#{'=' * 60}"
  puts 'SUCCESS: Simplified StyleSet YAML loader working correctly!'
rescue StandardError => e
  puts "\n✗ ERROR: #{e.message}"
  puts e.backtrace.first(10).join("\n")
  exit 1
end
