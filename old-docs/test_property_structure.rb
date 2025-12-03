#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lib/uniword'

puts 'Debugging Property Structure'
puts '=' * 60

# Test paragraph borders
puts "\n1. Paragraph borders structure:"
para = Uniword::Paragraph.new
para.set_borders(top: '000000', bottom: 'FF0000')

puts "para.properties: #{para.properties.inspect}"
puts "para.properties.borders: #{para.properties.borders.inspect}"
puts "para.properties.borders.top: #{para.properties.borders.top.inspect}"

# Try serializing just the properties
puts "\nSerialized properties:"
puts para.properties.to_xml

# Try serializing just the borders
puts "\nSerialized borders:"
puts para.properties.borders.to_xml

puts "\n#{'=' * 60}"
puts "\n2. Run character spacing structure:"
run = Uniword::Run.new(text: 'Test')
run.character_spacing = 20

puts "run.properties: #{run.properties.inspect}"
puts "run.properties.character_spacing: #{run.properties.character_spacing}"

# Try serializing just the properties
puts "\nSerialized properties:"
puts run.properties.to_xml
