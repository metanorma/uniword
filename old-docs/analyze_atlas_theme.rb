#!/usr/bin/env ruby
# frozen_string_literal: true

require 'zip'
require 'nokogiri'

# Simple ZipExtractor for this analysis
def extract_zip(path)
  content = {}
  Zip::File.open(path) do |zip_file|
    zip_file.each do |entry|
      next if entry.directory?

      content[entry.name] = entry.get_input_stream.read
    end
  end
  content
end

# Analyze Atlas.thmx structure
atlas_path = 'references/word-package/office-themes/Atlas.thmx'

puts '=' * 80
puts "Analyzing: #{atlas_path}"
puts '=' * 80
puts

# Extract ZIP contents
files = extract_zip(atlas_path)

puts 'Files in Atlas.thmx package:'
puts '-' * 80
files.keys.sort.each do |file_path|
  size = files[file_path].bytesize
  puts "  #{file_path} (#{size} bytes)"
end
puts

# Check for theme variants
variant_files = files.keys.select { |path| path.start_with?('theme/themeVariant/') }

if variant_files.any?
  puts 'Theme Variants Found:'
  puts '-' * 80
  variant_files.each do |variant_path|
    variant_name = File.basename(variant_path, '.xml')
    puts "  #{variant_name}"

    # Parse variant XML to get name
    xml = files[variant_path]
    doc = Nokogiri::XML(xml)
    name_attr = doc.root['name'] if doc.root
    puts "    Name attribute: #{name_attr}" if name_attr
  end
else
  puts 'No theme variants found in this package.'
end
puts

# Parse theme1.xml
theme_xml = files['theme/theme1.xml']
if theme_xml
  puts 'Theme Definition (theme1.xml):'
  puts '-' * 80

  doc = Nokogiri::XML(theme_xml)
  theme_node = doc.at_xpath('//a:theme', 'a' => 'http://schemas.openxmlformats.org/drawingml/2006/main')

  if theme_node
    puts "  Theme Name: #{theme_node['name']}"

    # Color scheme
    color_node = doc.at_xpath('//a:clrScheme', 'a' => 'http://schemas.openxmlformats.org/drawingml/2006/main')
    if color_node
      puts "  Color Scheme: #{color_node['name']}"

      # Show first few colors as example
      puts '  Sample Colors:'
      %w[dk1 lt1 accent1 accent2].each do |color_name|
        color_elem = doc.at_xpath("//a:#{color_name}//a:srgbClr | //a:#{color_name}//a:sysClr",
                                  'a' => 'http://schemas.openxmlformats.org/drawingml/2006/main')
        if color_elem
          value = color_elem['val'] || color_elem['lastClr']
          puts "    #{color_name}: #{value}"
        end
      end
    end

    # Font scheme
    font_node = doc.at_xpath('//a:fontScheme', 'a' => 'http://schemas.openxmlformats.org/drawingml/2006/main')
    if font_node
      puts "  Font Scheme: #{font_node['name']}"

      major_font = doc.at_xpath('//a:majorFont/a:latin', 'a' => 'http://schemas.openxmlformats.org/drawingml/2006/main')
      minor_font = doc.at_xpath('//a:minorFont/a:latin', 'a' => 'http://schemas.openxmlformats.org/drawingml/2006/main')

      puts "    Major Font (Headings): #{major_font['typeface']}" if major_font
      puts "    Minor Font (Body): #{minor_font['typeface']}" if minor_font
    end
  end
  puts
end

# Now check the reference document
puts '=' * 80
puts 'Analyzing Reference Document: namespace_demo_with_atlas_theme_variant_fancy.docx'
puts '=' * 80
puts

ref_files = extract_zip('namespace_demo_with_atlas_theme_variant_fancy.docx')

# Check if it has a theme
if ref_files['word/theme/theme1.xml']
  puts 'Reference document contains theme file: word/theme/theme1.xml'

  ref_theme_xml = ref_files['word/theme/theme1.xml']
  ref_doc = Nokogiri::XML(ref_theme_xml)
  ref_theme_node = ref_doc.at_xpath('//a:theme', 'a' => 'http://schemas.openxmlformats.org/drawingml/2006/main')

  puts "  Theme Name in document: #{ref_theme_node['name']}" if ref_theme_node

  # Check for any variant information
  variant_ref = ref_doc.at_xpath('//a:themeVariant', 'a' => 'http://schemas.openxmlformats.org/drawingml/2006/main')
  if variant_ref
    puts "  Variant reference found: #{variant_ref['name']}"
  else
    puts '  No explicit variant reference in theme XML'
  end

  puts
  puts 'First 500 chars of theme XML:'
  puts ref_theme_xml[0..500]
else
  puts 'Reference document does not contain theme file'
end

puts
puts '=' * 80
puts 'Analysis Complete'
puts '=' * 80
