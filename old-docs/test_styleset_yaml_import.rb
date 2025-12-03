#!/usr/bin/env ruby
# frozen_string_literal: true

# Test script for StyleSet YAML import system
# Tests both import (.dotx -> YAML) and load (YAML -> StyleSet)

# Load only what we need for StyleSet testing
require 'lutaml/model'
require_relative 'lib/uniword/style'
require_relative 'lib/uniword/styleset'
require_relative 'lib/uniword/stylesets/styleset_loader'
require_relative 'lib/uniword/stylesets/styleset_importer'
require_relative 'lib/uniword/stylesets/yaml_styleset_loader'

puts '=' * 80
puts 'StyleSet YAML Import System Test'
puts '=' * 80
puts

# Test 1: Import from .dotx
puts 'Test 1: Import StyleSet from .dotx to YAML'
puts '-' * 80

dotx_path = 'references/word-package/style-sets/Distinctive.dotx'
yaml_path = '/tmp/test_distinctive.yml'

if File.exist?(dotx_path)
  begin
    importer = Uniword::StyleSets::StyleSetImporter.new
    importer.import(dotx_path, yaml_path)

    puts "✓ Successfully imported #{dotx_path} to #{yaml_path}"
    puts "  File size: #{File.size(yaml_path)} bytes"

    # Show first few lines of YAML
    content = File.read(yaml_path)
    lines = content.lines.first(15)
    puts "\n  YAML Preview:"
    lines.each { |line| puts "    #{line}" }
    puts '    ...' if content.lines.size > 15
  rescue StandardError => e
    puts "✗ Import failed: #{e.message}"
    puts e.backtrace.first(3)
  end
else
  puts "⊘ Skipping: #{dotx_path} not found"
end

puts

# Test 2: Load from YAML
puts 'Test 2: Load StyleSet from YAML'
puts '-' * 80

if File.exist?(yaml_path)
  begin
    loader = Uniword::StyleSets::YamlStyleSetLoader.new
    styleset = loader.load(yaml_path)

    puts "✓ Successfully loaded StyleSet from #{yaml_path}"
    puts "  Name: #{styleset.name}"
    puts "  Source: #{styleset.source_file}"
    puts "  Total styles: #{styleset.styles.count}"

    # Show style breakdown by type
    puts "\n  Style Breakdown:"
    puts "    Paragraph styles: #{styleset.paragraph_styles.count}"
    puts "    Character styles: #{styleset.character_styles.count}"
    puts "    Table styles: #{styleset.table_styles.count}"

    # Show first few styles
    puts "\n  Sample Styles:"
    styleset.styles.first(5).each do |style|
      puts "    - #{style.name} (#{style.type})"
    end
  rescue StandardError => e
    puts "✗ Load failed: #{e.message}"
    puts e.backtrace.first(3)
  end
else
  puts "⊘ Skipping: #{yaml_path} not found"
end

puts

# Test 3: Round-trip verification
puts 'Test 3: Round-trip Verification'
puts '-' * 80

if File.exist?(dotx_path) && File.exist?(yaml_path)
  begin
    # Load original from .dotx
    original_loader = Uniword::StyleSets::StyleSetLoader.new
    original = original_loader.load(dotx_path)

    # Load from YAML
    yaml_loader = Uniword::StyleSets::YamlStyleSetLoader.new
    from_yaml = yaml_loader.load(yaml_path)

    # Compare
    puts 'Comparing original (.dotx) vs YAML-loaded StyleSet:'
    puts "  Name match: #{original.name == from_yaml.name ? '✓' : '✗'}"
    puts "  Style count match: #{original.styles.count == from_yaml.styles.count ? '✓' : '✗'}"
    puts "    Original: #{original.styles.count} styles"
    puts "    From YAML: #{from_yaml.styles.count} styles"

    # Check first few styles match
    matches = 0
    mismatches = 0
    original.styles.first(10).each_with_index do |orig_style, i|
      yaml_style = from_yaml.styles[i]
      if orig_style.id == yaml_style.id && orig_style.type == yaml_style.type
        matches += 1
      else
        mismatches += 1
        puts "  Mismatch at index #{i}: #{orig_style.id} vs #{yaml_style.id}"
      end
    end

    puts "  Style comparison (first 10): #{matches} matches, #{mismatches} mismatches"

    if matches.positive? && mismatches.zero?
      puts "\n✓ Round-trip successful!"
    else
      puts "\n⚠ Round-trip has discrepancies"
    end
  rescue StandardError => e
    puts "✗ Round-trip test failed: #{e.message}"
    puts e.backtrace.first(3)
  end
else
  puts '⊘ Skipping: Required files not found'
end

puts

# Test 4: Bundled StyleSet loader (if data directory exists)
puts 'Test 4: Bundled StyleSet Loader'
puts '-' * 80

begin
  available = Uniword::StyleSets::YamlStyleSetLoader.available_stylesets

  if available.empty?
    puts 'No bundled StyleSets found in data/stylesets/'
    puts "Run 'ruby bin/import_stylesets.rb' to create bundled StyleSets"
  else
    puts "Available bundled StyleSets: #{available.count}"
    available.each { |name| puts "  - #{name}" }

    # Try loading first bundled StyleSet
    if available.any?
      test_name = available.first
      puts "\nTesting load_bundled('#{test_name}'):"
      bundled = Uniword::StyleSets::YamlStyleSetLoader.load_bundled(test_name)
      puts "  ✓ Loaded: #{bundled.name}"
      puts "  Styles: #{bundled.styles.count}"
    end
  end
rescue StandardError => e
  puts "Error checking bundled StyleSets: #{e.message}"
end

puts
puts '=' * 80
puts 'Test Complete'
puts '=' * 80
