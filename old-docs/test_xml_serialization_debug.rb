#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lib/uniword'

puts 'Testing XML Serialization of Enhanced Properties'
puts '=' * 60

# Test 1: Paragraph with borders
puts "\n1. Paragraph with borders:"
para = Uniword::Paragraph.new
para.set_borders(top: '000000', bottom: 'FF0000')
puts "Properties set: #{!para.properties.nil?}"
puts "Borders set: #{!para.properties&.borders.nil?}"
xml = para.to_xml
puts 'XML output:'
puts xml
puts

# Test 2: Run with character spacing
puts "\n2. Run with character spacing:"
run = Uniword::Run.new(text: 'Test')
run.character_spacing = 20
puts "Properties set: #{!run.properties.nil?}"
puts "Spacing set: #{run.properties&.character_spacing}"
xml = run.to_xml
puts 'XML output:'
puts xml
puts

# Test 3: Run with outline
puts "\n3. Run with outline:"
run2 = Uniword::Run.new(text: 'Test')
run2.outline = true
puts "Properties set: #{!run2.properties.nil?}"
puts "Outline set: #{run2.properties&.outline}"
xml = run2.to_xml
puts 'XML output:'
puts xml
