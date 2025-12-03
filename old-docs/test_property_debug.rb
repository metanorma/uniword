# frozen_string_literal: true

require_relative 'lib/uniword'
require 'nokogiri'

# Test 1: Run with character_spacing
run = Uniword::Run.new(text: 'Test')
run.character_spacing = 20

puts '=== Run with character_spacing ==='
puts "Properties object: #{run.properties.inspect}"
puts "Character spacing: #{run.properties.character_spacing}"

xml = run.to_xml
puts "\nGenerated XML:"
puts xml

doc = Nokogiri::XML(xml)
puts "\n=== Parsed XML structure ==="
puts doc.to_xml(indent: 2)

rpr = doc.at_xpath('//w:rPr', 'w' => 'http://schemas.openxmlformats.org/wordprocessingml/2006/main')
puts "\nFound w:rPr: #{rpr ? 'YES' : 'NO'}"
if rpr
  puts 'w:rPr content:'
  puts rpr.to_xml(indent: 2)
end

# Test 2: Paragraph with borders
puts "\n\n=== Paragraph with borders ==="
para = Uniword::Paragraph.new
para.set_borders(top: '000000', bottom: 'FF0000')

puts "Properties object: #{para.properties.inspect}"
puts "Borders: #{para.properties.borders.inspect}"

xml = para.to_xml
puts "\nGenerated XML:"
puts xml

doc = Nokogiri::XML(xml)
ppr = doc.at_xpath('//w:pPr', 'w' => 'http://schemas.openxmlformats.org/wordprocessingml/2006/main')
puts "\nFound w:pPr: #{ppr ? 'YES' : 'NO'}"
if ppr
  puts 'w:pPr content:'
  puts ppr.to_xml(indent: 2)
end
