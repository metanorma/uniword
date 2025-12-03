#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lib/uniword'

# Create a simple theme
theme = Uniword::Theme.new(name: 'Test Theme')

# Set some colors
theme.color_scheme[:accent1] = 'FF0000'
theme.color_scheme[:accent2] = '00FF00'

# Set fonts
theme.font_scheme.major_font = 'Arial'
theme.font_scheme.minor_font = 'Calibri'

# Try to serialize
puts '=== Testing Theme Serialization ==='
puts

begin
  xml = theme.to_xml
  puts 'SUCCESS! Generated XML:'
  puts xml
  puts
  puts "XML length: #{xml.length} characters"
rescue StandardError => e
  puts "ERROR: #{e.message}"
  puts e.backtrace.first(5)
end
