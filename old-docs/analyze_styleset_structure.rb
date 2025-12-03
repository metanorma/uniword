#!/usr/bin/env ruby
# frozen_string_literal: true

require 'zip'
require 'nokogiri'

# Analyze StyleSet .dotx structure
dotx_file = 'references/word-package/style-sets/Distinctive.dotx'
ref_doc = 'examples/sample-theme_celestial-style_distinctive.docx'

puts '=' * 80
puts 'StyleSet Analysis'
puts '=' * 80
puts

# Function to extract ZIP
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

# Analyze .dotx file
puts "Analyzing: #{dotx_file}"
puts '-' * 80
dotx_files = extract_zip(dotx_file)

puts 'Files in .dotx package:'
dotx_files.keys.sort.each do |file_path|
  size = dotx_files[file_path].bytesize
  puts "  #{file_path} (#{size} bytes)"
end
puts

# Check for styles.xml
if dotx_files['word/styles.xml']
  puts 'Found word/styles.xml'
  styles_xml = dotx_files['word/styles.xml']
  doc = Nokogiri::XML(styles_xml)

  # Count styles
  styles = doc.xpath('//w:style', 'w' => 'http://schemas.openxmlformats.org/wordprocessingml/2006/main')
  puts "  Total styles: #{styles.count}"

  # Show types
  types = {}
  styles.each do |style|
    type = style['type']
    types[type] ||= 0
    types[type] += 1
  end

  puts '  Style types:'
  types.each { |type, count| puts "    #{type}: #{count}" }

  # Show first few style names
  puts '  Sample style names:'
  styles.first(10).each do |style|
    style_id = style.attr('styleId') || style['w:styleId']
    name_node = style.at_xpath('w:name', 'w' => 'http://schemas.openxmlformats.org/wordprocessingml/2006/main')
    name = name_node ? name_node['w:val'] : 'Unknown'
    type = style.attr('type') || style['w:type']
    puts "    #{style_id} - #{name} (#{type})"
  end
  puts
end

# Check for theme
if dotx_files['word/theme/theme1.xml']
  puts 'Found word/theme/theme1.xml'
  theme_xml = dotx_files['word/theme/theme1.xml']
  doc = Nokogiri::XML(theme_xml)
  theme_node = doc.at_xpath('//a:theme', 'a' => 'http://schemas.openxmlformats.org/drawingml/2006/main')
  puts "  Theme name: #{theme_node['name']}" if theme_node
  puts
end

# Analyze reference document
puts '=' * 80
puts "Reference Document Analysis: #{ref_doc}"
puts '=' * 80
puts

ref_files = extract_zip(ref_doc)

puts "Has theme? #{ref_files.key?('word/theme/theme1.xml')}"
if ref_files['word/theme/theme1.xml']
  theme_xml = ref_files['word/theme/theme1.xml']
  doc = Nokogiri::XML(theme_xml)
  theme_node = doc.at_xpath('//a:theme', 'a' => 'http://schemas.openxmlformats.org/drawingml/2006/main')
  puts "  Theme name: #{theme_node['name']}" if theme_node
end
puts

puts "Has styles? #{ref_files.key?('word/styles.xml')}"
if ref_files['word/styles.xml']
  styles_xml = ref_files['word/styles.xml']
  doc = Nokogiri::XML(styles_xml)
  styles = doc.xpath('//w:style', 'w' => 'http://schemas.openxmlformats.org/wordprocessingml/2006/main')
  puts "  Total styles: #{styles.count}"

  # Show sample styles
  puts '  Sample styles:'
  styles.first(15).each do |style|
    style_id = style.attr('styleId') || style['w:styleId']
    name_node = style.at_xpath('w:name', 'w' => 'http://schemas.openxmlformats.org/wordprocessingml/2006/main')
    name = name_node ? name_node['w:val'] : 'Unknown'
    type = style.attr('type') || style['w:type']
    puts "    #{style_id} - #{name} (#{type})"
  end
end
puts

puts '=' * 80
puts 'Analysis Complete'
puts '=' * 80
