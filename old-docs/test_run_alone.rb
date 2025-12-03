# frozen_string_literal: true

require_relative 'lib/uniword'

# Test Run with properties
run = Uniword::Run.new(text: 'Test')
run.character_spacing = 20

puts 'Run object:'
puts "  properties = #{run.properties.inspect}"
puts "  properties.character_spacing = #{run.properties.character_spacing.inspect}"

puts "\nGenerated XML:"
xml = run.to_xml
puts xml

require 'nokogiri'
doc = Nokogiri::XML(xml)
puts "\nParsed structure:"
rpr = doc.at_xpath('//w:rPr', 'w' => 'http://schemas.openxmlformats.org/wordprocessingml/2006/main')
puts "Found w:rPr: #{rpr ? 'YES' : 'NO'}"
if rpr
  puts "  Content: #{rpr.to_xml}"
  spacing = rpr.at_xpath('w:spacing', 'w' => 'http://schemas.openxmlformats.org/wordprocessingml/2006/main')
  puts "  Found w:spacing: #{spacing ? 'YES' : 'NO'}"
end
