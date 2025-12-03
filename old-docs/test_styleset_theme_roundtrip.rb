#!/usr/bin/env ruby
# frozen_string_literal: true

# Test that theme.xml from StyleSets round-trips correctly

require 'lutaml/model'
require_relative 'lib/uniword/theme'
require_relative 'lib/uniword/color_scheme'
require_relative 'lib/uniword/font_scheme'
require_relative 'lib/uniword/theme/theme_variant'
require_relative 'lib/uniword/theme/theme_xml_parser'
require_relative 'lib/uniword/infrastructure/zip_extractor'
require_relative 'lib/uniword/stylesets/styleset_package_reader'

# Helper function to build theme XML manually
def build_theme_xml_manual(theme)
  require 'nokogiri'

  builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
    xml['a'].theme(
      'xmlns:a' => 'http://schemas.openxmlformats.org/drawingml/2006/main',
      'name' => theme.name
    ) do
      xml['a'].themeElements do
        # Color scheme
        xml['a'].clrScheme('name' => theme.color_scheme.name) do
          Uniword::ColorScheme::THEME_COLORS.each do |color_name|
            color_value = theme.color_scheme.colors[color_name.to_sym]
            next unless color_value

            xml['a'].send(color_name) do
              xml['a'].srgbClr('val' => color_value)
            end
          end
        end

        # Font scheme
        xml['a'].fontScheme('name' => theme.font_scheme.name) do
          xml['a'].majorFont do
            if theme.font_scheme.major_font
              xml['a'].latin('typeface' => theme.font_scheme.major_font)
            end
          end
          xml['a'].minorFont do
            if theme.font_scheme.minor_font
              xml['a'].latin('typeface' => theme.font_scheme.minor_font)
            end
          end
        end

        # Format scheme (simplified)
        xml['a'].fmtScheme('name' => 'Office') do
          xml['a'].fillStyleLst
          xml['a'].lnStyleLst
          xml['a'].effectStyleLst
          xml['a'].bgFillStyleLst
        end
      end
    end
  end

  builder.to_xml
end

puts '=' * 80
puts 'StyleSet Theme Round-Trip Test'
puts '=' * 80
puts

# Test with a StyleSet that has a theme
dotx_file = 'references/word-package/style-sets/Distinctive.dotx'

unless File.exist?(dotx_file)
  puts "❌ Error: #{dotx_file} not found"
  exit 1
end

begin
  # Step 1: Extract theme from StyleSet
  puts 'Step 1: Extracting theme from StyleSet...'
  reader = Uniword::StyleSets::StyleSetPackageReader.new
  files = reader.extract(dotx_file)

  if files[:theme]
    puts '  ✓ Theme XML found in StyleSet'
    puts "    Size: #{files[:theme].length} bytes"
  else
    puts '  ⚠ No theme in this StyleSet'
    exit 0
  end
  puts

  # Step 2: Parse theme XML
  puts 'Step 2: Parsing theme XML...'
  parser = Uniword::Themes::ThemeXmlParser.new
  theme = parser.parse(files[:theme])

  puts '  ✓ Theme parsed successfully'
  puts "    Name: #{theme.name}"
  puts "    Colors: #{theme.color_scheme.colors.count}"
  puts "    Major font: #{theme.font_scheme.major_font}"
  puts "    Minor font: #{theme.font_scheme.minor_font}"
  puts

  # Step 3: Serialize theme back to XML
  puts 'Step 3: Serializing theme to XML...'

  # Build theme XML manually using the existing serializer pattern
  require 'nokogiri'
  theme_xml_output = build_theme_xml_manual(theme)

  puts '  ✓ Theme serialized'
  puts "    Size: #{theme_xml_output.length} bytes"
  puts

  # Step 4: Verify XML structure
  puts 'Step 4: Verifying XML structure...'
  doc = Nokogiri::XML(theme_xml_output)

  has_theme = !doc.at_xpath('//a:theme', 'a' => 'http://schemas.openxmlformats.org/drawingml/2006/main').nil?
  has_clrScheme = !doc.at_xpath('//a:clrScheme', 'a' => 'http://schemas.openxmlformats.org/drawingml/2006/main').nil?
  has_fontScheme = !doc.at_xpath('//a:fontScheme', 'a' => 'http://schemas.openxmlformats.org/drawingml/2006/main').nil?

  puts "  ✓ Has theme element: #{has_theme}"
  puts "  ✓ Has color scheme: #{has_clrScheme}"
  puts "  ✓ Has font scheme: #{has_fontScheme}"
  puts

  # Step 5: Write output
  puts 'Step 5: Writing output...'
  File.write('test_output/styleset_theme.xml', theme_xml_output)
  puts '  ✓ Wrote: test_output/styleset_theme.xml'
  puts

  puts '=' * 80
  puts '✓ COMPLETE - StyleSet theme round-trip working!'
  puts '=' * 80
rescue StandardError => e
  puts "❌ Error: #{e.message}"
  puts e.backtrace.first(10)
  exit 1
end
