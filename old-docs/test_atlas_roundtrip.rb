#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lib/uniword'

puts '=== Testing Atlas Theme Round-Trip ==='
puts

# Load Atlas theme
atlas_path = 'references/word-package/office-themes/Atlas.thmx'
puts "Loading theme from: #{atlas_path}"

begin
  theme = Uniword::Theme.from_thmx(atlas_path)

  puts '✓ Theme loaded successfully'
  puts "  Name: #{theme.name}"
  puts "  Color Scheme: #{theme.color_scheme.name}"
  puts "  Font Scheme: #{theme.font_scheme.name}"
  puts "  Major Font: #{theme.font_scheme.major_font}"
  puts "  Minor Font: #{theme.font_scheme.minor_font}"
  puts

  # Try to serialize it
  puts 'Serializing theme to XML...'
  xml = theme.to_xml

  puts '✓ Serialization successful!'
  puts "  XML length: #{xml.length} characters"
  puts

  # Check colors
  puts 'Sample colors:'
  puts "  accent1: #{theme.color_scheme[:accent1]}"
  puts "  accent2: #{theme.color_scheme[:accent2]}"
  puts "  dk1: #{theme.color_scheme[:dk1]}"
  puts "  lt1: #{theme.color_scheme[:lt1]}"
  puts

  # Show first 500 chars of XML
  puts 'First 500 characters of XML:'
  puts xml[0...500]
  puts '...'
rescue StandardError => e
  puts "✗ ERROR: #{e.message}"
  puts e.backtrace.first(10)
end
