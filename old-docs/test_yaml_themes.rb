#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lib/uniword'

puts '=' * 80
puts 'YAML Theme Loading Test Suite'
puts '=' * 80
puts

# Test 1: List available themes
puts 'Test 1: Listing available bundled themes'
puts '-' * 80
begin
  themes = Uniword::Theme.available_themes
  puts "✓ Found #{themes.count} themes"
  puts "  Themes: #{themes.first(5).join(', ')}..."
  puts
rescue StandardError => e
  puts "✗ FAILED: #{e.message}"
  puts
end

# Test 2: Load theme from YAML
puts 'Test 2: Loading Atlas theme from YAML'
puts '-' * 80
begin
  theme = Uniword::Theme.load('atlas')
  puts '✓ Theme loaded successfully'
  puts "  Name: #{theme.name}"
  puts "  Colors: #{theme.color_scheme.colors.count} colors"
  puts '  Sample colors:'
  %i[dk1 lt1 accent1 accent2].each do |color|
    puts "    #{color}: #{theme.color_scheme[color]}"
  end
  puts "  Major font: #{theme.major_font}"
  puts "  Minor font: #{theme.minor_font}"
  puts "  Variants: #{theme.variants.count}"
  puts
rescue StandardError => e
  puts "✗ FAILED: #{e.message}"
  puts e.backtrace.first(5).join("\n")
  puts
end

# Test 3: Load theme with variant
puts 'Test 3: Loading Atlas theme with variant2'
puts '-' * 80
begin
  theme = Uniword::Theme.load('atlas', variant: 2)
  puts '✓ Theme with variant loaded successfully'
  puts "  Name: #{theme.name}"
  puts "  Colors: #{theme.color_scheme.colors.count}"
  puts '  Sample colors (should be from variant2):'
  %i[accent1 accent2].each do |color|
    puts "    #{color}: #{theme.color_scheme[color]}"
  end
  puts
rescue StandardError => e
  puts "✗ FAILED: #{e.message}"
  puts
end

# Test 4: Apply bundled theme to document
puts 'Test 4: Creating document with bundled Atlas theme'
puts '-' * 80
begin
  doc = Uniword::Document.new
  doc.add_paragraph('Heading 1', heading: :heading_1)
  doc.add_paragraph('This document uses the bundled Atlas theme loaded from YAML.')

  # Apply using new shorthand method
  doc.apply_theme('atlas')

  # Save
  output_path = 'test_yaml_atlas_themed.docx'
  doc.save(output_path)

  puts '✓ Document created with bundled theme'
  puts "  Output: #{output_path}"
  puts "  Theme applied: #{doc.theme.name}"
  puts
rescue StandardError => e
  puts "✗ FAILED: #{e.message}"
  puts e.backtrace.first(5).join("\n")
  puts
end

# Test 5: Apply bundled theme with variant
puts 'Test 5: Creating document with bundled theme variant'
puts '-' * 80
begin
  doc = Uniword::Document.new
  doc.add_paragraph('Heading 1', heading: :heading_1)
  doc.add_paragraph('This document uses Atlas theme variant2.')

  # Apply with variant
  doc.apply_theme('atlas', variant: 2)

  # Save
  output_path = 'test_yaml_atlas_variant2.docx'
  doc.save(output_path)

  puts '✓ Document created with theme variant'
  puts "  Output: #{output_path}"
  puts "  Theme applied: #{doc.theme.name}"
  puts
rescue StandardError => e
  puts "✗ FAILED: #{e.message}"
  puts
end

# Test 6: Load from YAML file path
puts 'Test 6: Loading theme from YAML file path'
puts '-' * 80
begin
  theme = Uniword::Theme.from_yaml('data/themes/office_theme.yml')
  puts '✓ Theme loaded from file path'
  puts "  Name: #{theme.name}"
  puts "  Variants: #{theme.variants.count}"
  puts
rescue StandardError => e
  puts "✗ FAILED: #{e.message}"
  puts
end

# Test 7: Test multiple themes
puts 'Test 7: Loading multiple different themes'
puts '-' * 80
begin
  theme_names = %w[office_theme badge berlin]
  theme_names.each do |name|
    theme = Uniword::Theme.load(name)
    puts "✓ #{name}: #{theme.name} (#{theme.color_scheme.colors.count} colors, #{theme.variants.count} variants)"
  end
  puts
rescue StandardError => e
  puts "✗ FAILED: #{e.message}"
  puts
end

# Test 8: Error handling
puts 'Test 8: Error handling for invalid inputs'
puts '-' * 80
begin
  # Test non-existent theme
  begin
    Uniword::Theme.load('nonexistent_theme')
    puts '✗ Should have raised error for non-existent theme'
  rescue ArgumentError => e
    puts '✓ Correctly raised error for non-existent theme'
    puts "  Message: #{e.message}"
  end

  # Test invalid variant
  begin
    Uniword::Theme.load('atlas', variant: 999)
    puts '✗ Should have raised error for invalid variant'
  rescue ArgumentError => e
    puts '✓ Correctly raised error for invalid variant'
    puts "  Message: #{e.message}"
  end

  puts
rescue StandardError => e
  puts "✗ FAILED: #{e.message}"
  puts
end

# Summary
puts '=' * 80
puts 'Test Suite Complete'
puts '=' * 80
puts
puts 'Output files created:'
puts '  - test_yaml_atlas_themed.docx'
puts '  - test_yaml_atlas_variant2.docx'
puts
puts 'Please open these files in Microsoft Word to verify theme application.'
puts 'YAML themes should work identically to .thmx themes but load faster!'
puts
