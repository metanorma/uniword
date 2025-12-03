#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lib/uniword'

puts '=' * 80
puts 'Word Theme Implementation Test Suite'
puts '=' * 80
puts

# Test 1: Load Office Theme
puts 'Test 1: Loading Office Theme (default theme)'
puts '-' * 80
begin
  theme = Uniword::Theme.from_thmx('references/word-package/office-themes/Office Theme.thmx')
  puts '✓ Theme loaded successfully'
  puts "  Name: #{theme.name}"
  puts "  Colors defined: #{theme.color_scheme.colors.keys.join(', ')}"
  puts "  Major font: #{theme.major_font}"
  puts "  Minor font: #{theme.minor_font}"
  puts "  Variants: #{theme.variants.keys.count}"
  puts
rescue StandardError => e
  puts "✗ FAILED: #{e.message}"
  puts e.backtrace.first(5).join("\n")
  puts
end

# Test 2: Load Atlas Theme with variants
puts 'Test 2: Loading Atlas Theme (with variants)'
puts '-' * 80
begin
  atlas = Uniword::Theme.from_thmx('references/word-package/office-themes/Atlas.thmx')
  puts '✓ Theme loaded successfully'
  puts "  Name: #{atlas.name}"
  puts "  Colors: #{atlas.color_scheme.colors.count} colors defined"
  puts '  Sample colors:'
  %i[dk1 lt1 accent1 accent2].each do |color|
    puts "    #{color}: #{atlas.color_scheme[color]}"
  end
  puts "  Major font: #{atlas.major_font}"
  puts "  Minor font: #{atlas.minor_font}"
  puts "  Variants found: #{atlas.variants.keys.join(', ')}"
  puts
rescue StandardError => e
  puts "✗ FAILED: #{e.message}"
  puts e.backtrace.first(5).join("\n")
  puts
end

# Test 3: Load theme with specific variant
puts 'Test 3: Loading Atlas Theme with variant2'
puts '-' * 80
begin
  variant_theme = Uniword::Theme.from_thmx('references/word-package/office-themes/Atlas.thmx',
                                           variant: 2)
  puts '✓ Variant theme loaded successfully'
  puts "  Name: #{variant_theme.name}"
  puts "  Colors defined: #{variant_theme.color_scheme.colors.count}"
  puts "  Major font: #{variant_theme.major_font}"
  puts "  Minor font: #{variant_theme.minor_font}"
  puts
rescue StandardError => e
  puts "✗ FAILED: #{e.message}"
  puts e.backtrace.first(5).join("\n")
  puts
end

# Test 4: Apply theme to new document
puts 'Test 4: Creating document with Atlas theme'
puts '-' * 80
begin
  doc = Uniword::Document.new
  doc.add_paragraph('Heading 1', heading: :heading_1)
  doc.add_paragraph('This is a sample document with the Atlas theme applied.')
  doc.add_paragraph('It should use the theme colors and fonts when opened in Word.')

  # Apply theme
  doc.apply_theme_file('references/word-package/office-themes/Atlas.thmx')

  # Save
  output_path = 'test_output_atlas_themed.docx'
  doc.save(output_path)

  puts '✓ Document created with theme'
  puts "  Output: #{output_path}"
  puts "  Theme applied: #{doc.theme.name}"
  puts "  Theme colors: #{doc.theme.color_scheme.colors.count}"
  puts
rescue StandardError => e
  puts "✗ FAILED: #{e.message}"
  puts e.backtrace.first(5).join("\n")
  puts
end

# Test 5: Apply theme with variant to new document
puts 'Test 5: Creating document with Atlas theme variant2'
puts '-' * 80
begin
  doc = Uniword::Document.new
  doc.add_paragraph('Heading 1', heading: :heading_1)
  doc.add_paragraph('This document uses Atlas theme with variant2.')
  doc.add_paragraph('The variant may provide different visual styling.')

  # Apply theme with variant
  doc.apply_theme_file('references/word-package/office-themes/Atlas.thmx', variant: 2)

  # Save
  output_path = 'test_output_atlas_variant2.docx'
  doc.save(output_path)

  puts '✓ Document created with theme variant'
  puts "  Output: #{output_path}"
  puts "  Theme applied: #{doc.theme.name}"
  puts
rescue StandardError => e
  puts "✗ FAILED: #{e.message}"
  puts e.backtrace.first(5).join("\n")
  puts
end

# Test 6: Apply theme to existing document
puts 'Test 6: Applying theme to existing document'
puts '-' * 80
begin
  # Load existing document
  doc = Uniword::Document.open('namespace_demo.docx')
  original_theme = doc.theme&.name

  puts "  Original theme: #{original_theme || 'None'}"

  # Apply new theme
  doc.apply_theme_file('references/word-package/office-themes/Atlas.thmx')

  # Save
  output_path = 'test_output_demo_with_atlas.docx'
  doc.save(output_path)

  puts '✓ Theme applied to existing document'
  puts "  Output: #{output_path}"
  puts "  New theme: #{doc.theme.name}"
  puts
rescue StandardError => e
  puts "✗ FAILED: #{e.message}"
  puts e.backtrace.first(5).join("\n")
  puts
end

# Test 7: Round-trip theme preservation
puts 'Test 7: Round-trip theme preservation'
puts '-' * 80
begin
  # Create document with theme
  doc1 = Uniword::Document.new
  doc1.add_paragraph('Test document')
  doc1.apply_theme_file('references/word-package/office-themes/Office Theme.thmx')
  doc1.save('test_roundtrip.docx')

  # Reload and check theme
  doc2 = Uniword::Document.open('test_roundtrip.docx')

  if doc2.theme && doc2.theme.name == doc1.theme.name
    puts '✓ Theme preserved in round-trip'
    puts "  Theme name: #{doc2.theme.name}"
    puts "  Colors match: #{doc2.theme.color_scheme.colors.keys.sort == doc1.theme.color_scheme.colors.keys.sort}"
  else
    puts '✗ Theme not preserved correctly'
    puts "  Original: #{doc1.theme.name}"
    puts "  Reloaded: #{doc2.theme&.name || 'None'}"
  end
  puts
rescue StandardError => e
  puts "✗ FAILED: #{e.message}"
  puts e.backtrace.first(5).join("\n")
  puts
end

# Test 8: Error handling
puts 'Test 8: Error handling for invalid inputs'
puts '-' * 80
begin
  # Test non-existent file
  begin
    Uniword::Theme.from_thmx('nonexistent.thmx')
    puts '✗ Should have raised error for non-existent file'
  rescue ArgumentError, Errno::ENOENT
    puts '✓ Correctly raised error for non-existent file'
  end

  # Test invalid variant
  begin
    Uniword::Theme.from_thmx('references/word-package/office-themes/Atlas.thmx', variant: 999)
    puts '✗ Should have raised error for invalid variant'
  rescue ArgumentError
    puts '✓ Correctly raised error for invalid variant'
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
puts '  - test_output_atlas_themed.docx'
puts '  - test_output_atlas_variant2.docx'
puts '  - test_output_demo_with_atlas.docx'
puts '  - test_roundtrip.docx'
puts
puts 'Please open these files in Microsoft Word to verify theme application.'
puts
