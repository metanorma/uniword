#!/usr/bin/env ruby
# frozen_string_literal: true

# Generate sample document with Celestial theme + Distinctive StyleSet
# This recreates: sample-theme_celestial-style_distinctive.docx

require 'lutaml/model'
require_relative 'lib/uniword/element'
require_relative 'lib/uniword/properties/paragraph_properties'
require_relative 'lib/uniword/properties/run_properties'
require_relative 'lib/uniword/properties/table_properties'
require_relative 'lib/uniword/style'
require_relative 'lib/uniword/styleset'
require_relative 'lib/uniword/theme'
require_relative 'lib/uniword/color_scheme'
require_relative 'lib/uniword/font_scheme'
require_relative 'lib/uniword/body'
require_relative 'lib/uniword/paragraph'
require_relative 'lib/uniword/run'
require_relative 'lib/uniword/text_element'
require_relative 'lib/uniword/document'
require_relative 'lib/uniword/styles_configuration'
require_relative 'lib/uniword/numbering_configuration'
require_relative 'lib/uniword/section'
require_relative 'lib/uniword/comments_part'
require_relative 'lib/uniword/tracked_changes'
require_relative 'lib/uniword/infrastructure/zip_extractor'
require_relative 'lib/uniword/themes/yaml_theme_loader'
require_relative 'lib/uniword/stylesets/yaml_styleset_loader'
require_relative 'lib/uniword/serialization/ooxml_serializer'
require_relative 'lib/uniword/infrastructure/zip_packager'
require_relative 'lib/uniword/ooxml/docx_packager'
require_relative 'lib/uniword/document_writer'
require_relative 'lib/uniword/formats/docx_handler'
require_relative 'lib/uniword/formats/mhtml_handler'

puts '=' * 80
puts 'Generate: Celestial Theme + Distinctive StyleSet Document'
puts '=' * 80
puts

output_file = 'examples/sample-theme_celestial-style_distinctive.docx'

begin
  # Step 1: Create document
  puts 'Step 1: Creating new document...'
  doc = Uniword::Document.new
  puts '  ✓ Document created'
  puts

  # Step 2: Load and apply Celestial theme
  puts 'Step 2: Loading Celestial theme...'
  theme = Uniword::Themes::YamlThemeLoader.load_bundled('celestial')
  doc.theme = theme
  puts "  ✓ Theme loaded: #{theme.name}"
  puts "    Colors: #{theme.color_scheme.colors.keys.count} theme colors"
  puts "    Fonts: #{theme.font_scheme.major_font} / #{theme.font_scheme.minor_font}"
  puts

  # Step 3: Load and apply Distinctive StyleSet
  puts 'Step 3: Loading Distinctive StyleSet...'
  styleset = Uniword::StyleSets::YamlStyleSetLoader.load_bundled('distinctive')
  styleset.apply_to(doc, strategy: :keep_existing)
  puts "  ✓ StyleSet applied: #{styleset.name}"
  puts "    Styles: #{doc.styles.count}"
  puts

  # Step 4: Add sample content using the styles
  puts 'Step 4: Adding sample content...'

  # Title
  para = Uniword::Paragraph.new
  para.set_style('Title')
  para.add_text('Sample Document')
  doc.add_element(para)

  # Heading 1
  para = Uniword::Paragraph.new
  para.set_style('Heading1')
  para.add_text('Introduction')
  doc.add_element(para)

  # Normal paragraph
  para = Uniword::Paragraph.new
  para.set_style('Normal')
  para.add_text('This document demonstrates the combination of the Celestial theme with the Distinctive StyleSet. ')
  para.add_text('The Celestial theme provides the color scheme and fonts, while the Distinctive StyleSet defines the style formatting.')
  doc.add_element(para)

  # Heading 2
  para = Uniword::Paragraph.new
  para.set_style('Heading2')
  para.add_text('Features')
  doc.add_element(para)

  # List items
  para = Uniword::Paragraph.new
  para.set_style('ListParagraph')
  para.add_text('Professional color scheme from Celestial theme')
  doc.add_element(para)

  para = Uniword::Paragraph.new
  para.set_style('ListParagraph')
  para.add_text('Distinctive heading styles with proper spacing')
  doc.add_element(para)

  para = Uniword::Paragraph.new
  para.set_style('ListParagraph')
  para.add_text('Complete property preservation through round-trip')
  doc.add_element(para)

  puts '  ✓ Added 7 paragraphs with various styles'
  puts

  # Step 5: Save document
  puts 'Step 5: Saving document...'

  # Ensure examples directory exists
  require 'fileutils'
  FileUtils.mkdir_p('examples')

  doc.save(output_file)

  file_size = File.size(output_file)
  puts "  ✓ Document saved: #{output_file}"
  puts "    File size: #{file_size} bytes (#{(file_size / 1024.0).round(2)} KB)"
  puts

  puts '=' * 80
  puts '✓ COMPLETE - Document generated successfully!'
  puts '=' * 80
  puts
  puts "Open in Word to view: #{output_file}"
  puts
rescue StandardError => e
  puts "❌ Error: #{e.message}"
  puts e.backtrace.first(15)
  exit 1
end
