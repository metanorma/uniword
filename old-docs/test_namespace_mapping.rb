# frozen_string_literal: true

require 'bundler/setup'
require_relative 'lib/uniword/ooxml/core_properties'

# Test serialization
props = Uniword::Ooxml::CoreProperties.new(
  title: 'Test Title',
  creator: 'Test Creator',
  keywords: 'test'
)

xml = props.to_xml
puts '=== Generated XML ==='
puts xml
puts ''

# Test if we can parse it back
begin
  restored = Uniword::Ooxml::CoreProperties.from_xml(xml)
  puts '=== Parsed Back ==='
  puts "Title: #{restored.title.inspect}"
  puts "Creator: #{restored.creator.inspect}"
  puts "Keywords: #{restored.keywords.inspect}"
rescue StandardError => e
  puts "ERROR: #{e.message}"
  puts e.backtrace[0..5]
end
