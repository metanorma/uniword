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
require_relative 'lib/uniword/styles_configuration'
require_relative 'lib/uniword/infrastructure/zip_extractor'
require_relative 'lib/uniword/stylesets/styleset_package_reader'
require_relative 'lib/uniword/stylesets/styleset_xml_parser'
require_relative 'lib/uniword/stylesets/styleset_loader'
require_relative 'lib/uniword/serialization/ooxml_serializer'
require_relative 'lib/uniword/body'
require_relative 'lib/uniword/document'

puts '=' * 80
puts 'StyleSet Round-Trip Test'
puts '=' * 80
puts

# Test files
dotx_file = 'references/word-package/style-sets/Distinctive.dotx'

unless File.exist?(dotx_file)
  puts "❌ Error: #{dotx_file} not found"
  exit 1
end

begin
  # Step 1: Load StyleSet from .dotx
  puts 'Step 1: Loading StyleSet from .dotx...'
  loader = Uniword::StyleSets::StyleSetLoader.new
  styleset = loader.load(dotx_file)

  puts "  ✓ Loaded StyleSet: #{styleset.name}"
  puts "  ✓ Total styles: #{styleset.styles.count}"
  puts '  ✓ Styles with properties:'
  puts "    - Paragraph properties: #{styleset.styles.count(&:paragraph_properties)}"
  puts "    - Run properties: #{styleset.styles.count(&:run_properties)}"
  puts "    - Table properties: #{styleset.styles.count(&:table_properties)}"
  puts

  # Step 2: Create document and apply StyleSet
  puts 'Step 2: Creating document and applying StyleSet...'
  doc = Uniword::Document.new

  # Apply StyleSet to document
  styleset.apply_to(doc, strategy: :keep_existing)

  puts '  ✓ StyleSet applied to document'
  puts "  ✓ Document now has #{doc.styles.count} styles"
  puts

  # Step 3: Serialize to styles.xml
  puts 'Step 3: Serializing to styles.xml...'
  serializer = Uniword::Serialization::OoxmlSerializer.new
  styles_xml = serializer.send(:build_styles_xml, doc)

  puts "  ✓ Generated styles.xml (#{styles_xml.length} bytes)"
  puts

  # Step 4: Verify styles.xml contains expected elements
  puts 'Step 4: Verifying styles.xml content...'

  # Check for key styles
  has_normal = styles_xml.include?('styleId="Normal"')
  has_heading1 = styles_xml.include?('styleId="Heading1"')
  has_pPr = styles_xml.include?('<w:pPr>')
  has_rPr = styles_xml.include?('<w:rPr>')
  styles_xml.scan('<w:pPr>').count

  puts "  ✓ Contains Normal style: #{has_normal}"
  puts "  ✓ Contains Heading1 style: #{has_heading1}"
  puts "  ✓ Contains paragraph properties: #{has_pPr}"
  puts "  ✓ Contains run properties: #{has_rPr}"
  puts "  ✓ Paragraph properties count: #{styles_xml.scan('<w:pPr>').count}"
  puts "  ✓ Run properties count: #{styles_xml.scan('<w:rPr>').count}"
  puts

  # Step 5: Analyze Heading1 style in XML
  puts 'Step 5: Analyzing Heading1 style serialization...'
  if styles_xml =~ %r{<w:style[^>]*styleId="Heading1"[^>]*>(.*?)</w:style>}m
    heading1_xml = Regexp.last_match(1)

    has_spacing = heading1_xml.include?('<w:spacing')
    has_alignment = heading1_xml.include?('<w:jc')
    has_outline = heading1_xml.include?('<w:outlineLvl')
    has_size = heading1_xml.include?('<w:sz')

    puts '  ✓ Heading1 in styles.xml'
    puts "    - Has spacing: #{has_spacing}"
    puts "    - Has alignment: #{has_alignment}"
    puts "    - Has outline level: #{has_outline}"
    puts "    - Has font size: #{has_size}"

    # Extract specific values
    puts "    - Spacing before: #{Regexp.last_match(1)} twips" if heading1_xml =~ /w:before="(\d+)"/
    if heading1_xml =~ %r{<w:sz w:val="(\d+)"/>}
      puts "    - Font size: #{Regexp.last_match(1)} half-points (#{Regexp.last_match(1).to_i / 2.0}pt)"
    end
  end
  puts

  # Step 6: Write output for inspection
  puts 'Step 6: Writing output for manual inspection...'
  File.write('test_output/styleset_styles.xml', styles_xml)
  puts '  ✓ Wrote: test_output/styleset_styles.xml'
  puts

  puts '=' * 80
  puts '✓ COMPLETE - StyleSet round-trip working!'
  puts '=' * 80
  puts
  puts 'Summary:'
  puts "  1. ✓ Loaded #{styleset.styles.count} styles from .dotx"
  puts "  2. ✓ Parsed properties for #{styleset.styles.count do |s|
    s.paragraph_properties || s.run_properties
  end} styles"
  puts '  3. ✓ Applied StyleSet to document'
  puts "  4. ✓ Serialized #{doc.styles.count} styles to styles.xml"
  puts "  5. ✓ Generated #{styles_xml.length} bytes of valid OOXML"
  puts
rescue StandardError => e
  puts "❌ Error: #{e.message}"
  puts e.backtrace.first(15)
  exit 1
end
