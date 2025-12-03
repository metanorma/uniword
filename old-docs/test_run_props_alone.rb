# frozen_string_literal: true

require_relative 'lib/uniword'

# Test RunProperties with CharacterSpacing
props = Uniword::Properties::RunProperties.new
props.character_spacing = Uniword::Properties::CharacterSpacing.new(val: 20)

puts 'RunProperties object:'
puts "  character_spacing = #{props.character_spacing.inspect}"
puts "  character_spacing.val = #{props.character_spacing.val}"

puts "\nGenerated XML:"
xml = props.to_xml
puts xml

require 'nokogiri'
doc = Nokogiri::XML(xml)
puts "\nParsed structure:"
spacing = doc.at_xpath('//w:spacing', 'w' => 'http://schemas.openxmlformats.org/wordprocessingml/2006/main')
puts "Found w:spacing: #{spacing ? 'YES' : 'NO'}"
puts "  w:val = #{spacing['val']}" if spacing
