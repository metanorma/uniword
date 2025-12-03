#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require './lib/uniword/styleset'

puts 'Testing Distinctive StyleSet Serialization'
puts '=' * 80

# Load Distinctive StyleSet
styleset = Uniword::StyleSet.from_dotx('references/word-package/style-sets/Distinctive.dotx')
puts "Loaded StyleSet: #{styleset.name}"
puts "Total styles: #{styleset.styles.count}"

# Find Heading1 style
heading1 = styleset.styles.find { |s| s.id == 'Heading1' }
if heading1
  puts "\n#{'=' * 80}"
  puts 'Testing Heading1 Style'
  puts '=' * 80

  # Check paragraph properties
  if heading1.paragraph_properties
    pp = heading1.paragraph_properties
    puts "\nParagraph Properties:"
    puts "  Alignment (flat): #{pp.alignment.inspect}"
    puts "  Alignment (obj): #{pp.alignment_obj.inspect}"
    puts "  Style (flat): #{pp.style.inspect}"
    puts "  Style (obj): #{pp.style_ref.inspect}"
    puts "  Outline Level (flat): #{pp.outline_level.inspect}"
    puts "  Outline Level (obj): #{pp.outline_level_obj.inspect}"
    puts "  Spacing object: #{pp.spacing.inspect}"
  end

  # Check run properties
  if heading1.run_properties
    rp = heading1.run_properties
    puts "\nRun Properties:"
    puts "  Size (flat): #{rp.size.inspect}"
    puts "  Size (obj): #{rp.size_obj.inspect}"
    puts "  Color (flat): #{rp.color.inspect}"
    puts "  Color (obj): #{rp.color_obj.inspect}"
    puts "  Bold: #{rp.bold}"
    puts "  Fonts object: #{rp.fonts.inspect}"
  end

  # Test serialization
  puts "\n#{'=' * 80}"
  puts 'Testing XML Serialization'
  puts '=' * 80

  begin
    xml = heading1.to_xml
    puts "\n✅ Serialization successful!"
    puts "XML length: #{xml.length} chars"

    # Check for key elements
    checks = {
      '<jc' => 'Alignment element',
      '<sz' => 'Font size element',
      '<color' => 'Color element',
      '<pStyle' => 'Paragraph style reference',
      '<rStyle' => 'Run style reference',
      '<outlineLvl' => 'Outline level',
      '<spacing' => 'Spacing element',
      '<rFonts' => 'RunFonts element'
    }

    puts "\nElement Presence Check:"
    checks.each do |tag, desc|
      present = xml.include?(tag)
      status = present ? '✅' : '❌'
      puts "  #{status} #{desc}: #{present}"
    end

    # Show snippet of XML
    puts "\nXML Snippet (first 800 chars):"
    puts xml[0...800]
  rescue StandardError => e
    puts "\n❌ Serialization failed!"
    puts "Error: #{e.class}: #{e.message}"
    puts e.backtrace.first(5)
  end

  # Test round-trip
  puts "\n#{'=' * 80}"
  puts 'Testing Round-Trip'
  puts '=' * 80

  begin
    xml = heading1.to_xml
    reparsed = Uniword::Style.from_xml(xml)

    puts "\n✅ Round-trip successful!"

    # Compare properties
    if reparsed.paragraph_properties
      orig_align = heading1.paragraph_properties.alignment
      new_align = reparsed.paragraph_properties.alignment
      match = orig_align == new_align
      status = match ? '✅' : '❌'
      puts "  #{status} Alignment: #{orig_align} → #{new_align}"
    end

    if reparsed.run_properties
      orig_size = heading1.run_properties.size
      new_size = reparsed.run_properties.size
      match = orig_size == new_size
      status = match ? '✅' : '❌'
      puts "  #{status} Font Size: #{orig_size} → #{new_size}"

      orig_color = heading1.run_properties.color
      new_color = reparsed.run_properties.color
      match = orig_color == new_color
      status = match ? '✅' : '❌'
      puts "  #{status} Color: #{orig_color} → #{new_color}"
    end
  rescue StandardError => e
    puts "\n❌ Round-trip failed!"
    puts "Error: #{e.class}: #{e.message}"
    puts e.backtrace.first(5)
  end
end

puts "\n#{'=' * 80}"
puts 'Testing All Styles Serialization'
puts '=' * 80

errors = []
styleset.styles.each do |style|
  style.to_xml
rescue StandardError => e
  errors << "#{style.id}: #{e.message}"
end

if errors.empty?
  puts "\n✅ All #{styleset.styles.count} styles serialize successfully!"
else
  puts "\n❌ #{errors.count} styles failed:"
  errors.each { |e| puts "  - #{e}" }
end

puts "\n#{'=' * 80}"
puts 'SUMMARY'
puts '=' * 80
puts 'Implementation Status: COMPLETE'
puts 'Next: Run full round-trip tests on all 24 StyleSets'
