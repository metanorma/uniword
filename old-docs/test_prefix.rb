# frozen_string_literal: true

require_relative 'lib/uniword'

run = Uniword::Run.new(text: 'Test')
run.character_spacing = 20

puts '=== Without prefix ==='
puts run.to_xml
puts ''

puts '=== With prefix: true ==='
puts run.to_xml(prefix: true)
puts ''

# Test with nokogiri parsing
require 'nokogiri'
doc = Nokogiri::XML(run.to_xml(prefix: true))
spacing = doc.at_xpath('//w:spacing', 'w' => 'http://schemas.openxmlformats.org/wordprocessingml/2006/main')
if spacing
  puts 'Found spacing element'
  puts "spacing['val'] = #{spacing['val'].inspect}"
  puts "spacing['w:val'] = #{spacing['w:val'].inspect}"
end
