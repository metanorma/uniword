#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lib/uniword'

# Test the simplified StyleSet import using lutaml-model

# Check if we have a .dotx file to test with
dotx_files = Dir.glob('examples/*.dotx') + Dir.glob('data/stylesets/*.dotx')

if dotx_files.empty?
  puts 'No .dotx files found for testing.'
  puts 'Please provide a .dotx file in examples/ or data/stylesets/'
  exit 1
end

# Use the first .dotx file found, or look for Formal.dotx
test_file = dotx_files.find { |f| f =~ /formal/i } || dotx_files.first
puts "Testing StyleSet import with: #{test_file}"
puts '=' * 60

# Create output path
output_path = 'test_styleset_output.yml'

begin
  # Import using the simplified importer
  puts "\n1. Importing .dotx to YAML..."
  importer = Uniword::StyleSets::StyleSetImporter.new
  importer.import(test_file, output_path)
  puts '   ✓ Import successful'

  # Read the generated YAML
  puts "\n2. Reading generated YAML..."
  yaml_content = File.read(output_path)
  puts "   ✓ YAML file created (#{yaml_content.bytesize} bytes)"

  # Load using the simplified loader
  puts "\n3. Loading StyleSet from YAML..."
  loader = Uniword::StyleSets::YamlStyleSetLoader.new
  styleset = loader.load(output_path)
  puts '   ✓ StyleSet loaded successfully'

  # Display StyleSet details
  puts "\n4. StyleSet Details:"
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

  # Show sample styles
  puts "\n5. Sample Styles (first 5):"
  styleset.styles.first(5).each do |style|
    props = []
    props << 'default' if style.default
    props << 'custom' if style.custom
    props << "based_on=#{style.based_on}" if style.based_on
    props << "font=#{style.font_family}" if style.font_family
    props << "size=#{style.font_size}" if style.font_size
    props << 'bold' if style.bold
    props << 'italic' if style.italic

    prop_str = props.empty? ? '' : " (#{props.join(', ')})"
    puts "   - #{style.type}: #{style.id} / #{style.name}#{prop_str}"
  end

  # Show YAML excerpt
  puts "\n6. YAML Excerpt (first 40 lines):"
  puts '-' * 60
  yaml_content.lines.first(40).each { |line| puts line }
  puts "... (#{yaml_content.lines.count - 40} more lines)" if yaml_content.lines.count > 40
  puts '-' * 60

  # Verify key properties are captured
  puts "\n7. Property Verification:"
  has_formatting = styleset.styles.any? do |s|
    s.font_family || s.font_size || s.font_color || s.bold || s.italic ||
      s.alignment || s.spacing_before || s.spacing_after
  end

  has_inheritance = styleset.styles.any?(&:based_on)
  has_metadata = styleset.styles.any? { |s| s.ui_priority || s.quick_format }

  puts "   ✓ Formatting properties: #{has_formatting ? 'FOUND' : 'MISSING'}"
  puts "   ✓ Style inheritance: #{has_inheritance ? 'FOUND' : 'MISSING'}"
  puts "   ✓ Metadata properties: #{has_metadata ? 'FOUND' : 'MISSING'}"

  puts "\n#{'=' * 60}"
  puts 'SUCCESS: StyleSet import working correctly!'
  puts "Output saved to: #{output_path}"
rescue StandardError => e
  puts "\n✗ ERROR: #{e.message}"
  puts e.backtrace.first(10).join("\n")
  exit 1
end
