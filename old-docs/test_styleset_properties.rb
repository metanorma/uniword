#!/usr/bin/env ruby
# frozen_string_literal: true

# Load only what we need for StyleSet testing
require 'lutaml/model'
require_relative 'lib/uniword/element'
require_relative 'lib/uniword/properties/paragraph_properties'
require_relative 'lib/uniword/properties/run_properties'
require_relative 'lib/uniword/properties/table_properties'
require_relative 'lib/uniword/style'
require_relative 'lib/uniword/styleset'
require_relative 'lib/uniword/infrastructure/zip_extractor'
require_relative 'lib/uniword/stylesets/styleset_package_reader'
require_relative 'lib/uniword/stylesets/styleset_xml_parser'
require_relative 'lib/uniword/stylesets/styleset_loader'

puts '=' * 80
puts 'StyleSet Property Parsing Test'
puts '=' * 80
puts

# Test with Distinctive.dotx (should be in references directory)
dotx_file = 'references/word-package/style-sets/Distinctive.dotx'

unless File.exist?(dotx_file)
  puts "❌ Error: #{dotx_file} not found"
  puts 'Please ensure the .dotx file exists'
  exit 1
end

puts "Loading StyleSet from: #{dotx_file}"
puts

begin
  # Load the StyleSet
  loader = Uniword::StyleSets::StyleSetLoader.new
  styleset = loader.load(dotx_file)

  puts '✓ StyleSet loaded successfully'
  puts "  Name: #{styleset.name}"
  puts "  Styles: #{styleset.styles.count}"
  puts

  # Analyze property parsing
  styles_with_pPr = 0
  styles_with_rPr = 0
  styles_with_tblPr = 0

  styleset.styles.each do |style|
    styles_with_pPr += 1 if style.paragraph_properties
    styles_with_rPr += 1 if style.run_properties
    styles_with_tblPr += 1 if style.table_properties
  end

  puts 'Property Parsing Summary:'
  puts "  Styles with paragraph properties: #{styles_with_pPr}"
  puts "  Styles with run properties: #{styles_with_rPr}"
  puts "  Styles with table properties: #{styles_with_tblPr}"
  puts

  # Examine a specific style in detail
  normal_style = styleset.styles.find { |s| s.id == 'Normal' }
  if normal_style
    puts 'Detailed Analysis: Normal Style'
    puts "  ID: #{normal_style.id}"
    puts "  Name: #{normal_style.name}"
    puts "  Type: #{normal_style.type}"
    puts

    if normal_style.paragraph_properties
      pPr = normal_style.paragraph_properties
      puts '  Paragraph Properties:'
      puts "    Alignment: #{pPr.alignment}" if pPr.alignment
      puts "    Spacing before: #{pPr.spacing_before}" if pPr.spacing_before
      puts "    Spacing after: #{pPr.spacing_after}" if pPr.spacing_after
      puts "    Line spacing: #{pPr.line_spacing}" if pPr.line_spacing
      puts "    Line rule: #{pPr.line_rule}" if pPr.line_rule
      puts "    Indent left: #{pPr.indent_left}" if pPr.indent_left
      puts "    Indent right: #{pPr.indent_right}" if pPr.indent_right
      puts "    Indent first line: #{pPr.indent_first_line}" if pPr.indent_first_line
      puts "    Keep next: #{pPr.keep_next}" if pPr.keep_next
      puts "    Widow control: #{pPr.widow_control}" unless pPr.widow_control.nil?
    else
      puts '  ⚠ No paragraph properties parsed'
    end
    puts

    if normal_style.run_properties
      rPr = normal_style.run_properties
      puts '  Run Properties:'
      puts "    Font: #{rPr.font}" if rPr.font
      puts "    Font ASCII: #{rPr.font_ascii}" if rPr.font_ascii
      puts "    Size: #{rPr.size} half-points" if rPr.size
      puts "    Bold: #{rPr.bold}" if rPr.bold
      puts "    Italic: #{rPr.italic}" if rPr.italic
      puts "    Color: #{rPr.color}" if rPr.color
      puts "    Underline: #{rPr.underline}" if rPr.underline
      puts "    Character spacing: #{rPr.spacing}" if rPr.spacing
    else
      puts '  ⚠ No run properties parsed'
    end
  else
    puts '⚠ Normal style not found'
  end
  puts

  # Examine Heading 1
  heading1 = styleset.styles.find { |s| s.id == 'Heading1' }
  if heading1
    puts 'Detailed Analysis: Heading 1 Style'
    puts "  ID: #{heading1.id}"
    puts "  Name: #{heading1.name}"
    puts "  Based on: #{heading1.based_on}" if heading1.based_on
    puts

    if heading1.paragraph_properties
      pPr = heading1.paragraph_properties
      puts '  Paragraph Properties:'
      puts "    Alignment: #{pPr.alignment}" if pPr.alignment
      puts "    Spacing before: #{pPr.spacing_before}" if pPr.spacing_before
      puts "    Spacing after: #{pPr.spacing_after}" if pPr.spacing_after
      puts "    Keep next: #{pPr.keep_next}" if pPr.keep_next
      puts "    Keep lines: #{pPr.keep_lines}" if pPr.keep_lines
      puts "    Page break before: #{pPr.page_break_before}" if pPr.page_break_before
      puts "    Outline level: #{pPr.outline_level}" if pPr.outline_level
      puts
    end

    if heading1.run_properties
      rPr = heading1.run_properties
      puts '  Run Properties:'
      puts "    Font: #{rPr.font}" if rPr.font
      puts "    Size: #{rPr.size} half-points (#{rPr.size / 2.0}pt)" if rPr.size
      puts "    Bold: #{rPr.bold}" if rPr.bold
      puts "    Color: #{rPr.color}" if rPr.color
      puts
    end
  end

  puts '=' * 80
  puts '✓ TEST COMPLETE - Property parsing working!'
  puts '=' * 80
rescue StandardError => e
  puts "❌ Error: #{e.message}"
  puts e.backtrace.first(10)
  exit 1
end
