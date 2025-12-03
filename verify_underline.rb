#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require_relative 'lib/uniword'

puts '=' * 60
puts 'Underline Property Verification'
puts '=' * 60
puts

# Test with .dotx file directly
puts 'Test 1: Loading StyleSet from .dotx file...'
dotx_path = 'references/word-package/style-sets/Distinctive.dotx'

if File.exist?(dotx_path)
  styleset = Uniword::StyleSet.from_dotx(dotx_path)
  puts '✓ Loaded StyleSet from .dotx'
  puts "  Name: #{styleset.name}"
  puts "  Total styles: #{styleset.styles.count}"

  # Find styles with underline
  styles_with_underline = styleset.styles.select do |style|
    style.run_properties&.underline
  end

  puts "  Styles with underline: #{styles_with_underline.count}"
  puts

  # Test 2: Check underline accessibility
  if styles_with_underline.any?
    style = styles_with_underline.first
    puts 'Test 2: Checking underline value access...'
    puts "  Style: #{style.name} (#{style.id})"
    puts "  Underline value: #{style.run_properties.underline.value}"
    puts '  ✓ Underline accessible via .value'
    puts

    # Test 3: Serialize to XML
    puts 'Test 3: Serializing style to XML...'
    xml = style.to_xml
    puts "  XML length: #{xml.length} bytes"

    # Check for underline element
    has_underline = xml.include?('<u ') || xml.include?('<w:u ')
    if has_underline
      puts '  ✓ XML contains underline element'

      # Extract underline snippet
      puts "  Underline XML: #{Regexp.last_match(1)}" if xml =~ %r{(<w?:?u [^>]+/>)}
    else
      puts '  ✗ XML missing underline element'
      puts '  First 500 chars of XML:'
      puts xml[0..500]
    end
    puts

    # Test 4: Round-trip deserialization
    puts 'Test 4: Testing round-trip...'
    reparsed = Uniword::Style.from_xml(xml)
    if reparsed.run_properties&.underline
      reparsed_value = reparsed.run_properties.underline.value
      original_value = style.run_properties.underline.value

      if reparsed_value == original_value
        puts '  ✓ Round-trip successful'
      else
        puts '  ✗ Round-trip failed - values differ'
      end
      puts "    Original: #{original_value}"
      puts "    Reparsed: #{reparsed_value}"
    else
      puts '  ✗ Round-trip failed - underline lost'
    end
    puts

    # Test 5: List all styles with underline
    puts 'Test 5: All styles with underline in this StyleSet:'
    styles_with_underline.each do |s|
      puts "  - #{s.name} (#{s.id}): #{s.run_properties.underline.value}"
    end
    puts
  else
    puts 'No styles with underline found in Distinctive StyleSet'
    puts 'This might be expected - not all StyleSets use underline'
  end

  # Test 6: Try other StyleSets
  puts 'Test 6: Checking other StyleSets for underline...'
  other_stylesets = Dir.glob('references/word-package/**/*.dotx').first(5)

  other_stylesets.each do |path|
    name = File.basename(path, '.dotx')
    ss = Uniword::StyleSet.from_dotx(path)
    count = ss.styles.count { |s| s.run_properties&.underline }
    puts "  #{name}: #{count} style(s) with underline" if count.positive?
  end

else
  puts "✗ .dotx file not found at #{dotx_path}"
  puts 'Please check the fixture path'
end

puts
puts '=' * 60
puts 'Verification Complete'
puts '=' * 60
