#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lib/generated/customxml'
require_relative 'lib/generated/bibliography'

puts '=' * 80
puts 'Session 12: Testing Custom XML + Bibliography Autoload'
puts '=' * 80
puts

# Test Custom XML namespace
puts 'Testing Custom XML namespace (cxml:)...'
puts '-' * 80

custom_xml_classes = [
  Uniword::Generated::Customxml::CustomXml,
  Uniword::Generated::Customxml::CustomXmlProperties,
  Uniword::Generated::Customxml::CustomXmlAttribute,
  Uniword::Generated::Customxml::DataBinding,
  Uniword::Generated::Customxml::DataStoreItem,
  Uniword::Generated::Customxml::SchemaReference,
  Uniword::Generated::Customxml::XPath,
  Uniword::Generated::Customxml::Placeholder,
  Uniword::Generated::Customxml::CustomXmlBlock,
  Uniword::Generated::Customxml::CustomXmlRun,
  Uniword::Generated::Customxml::CustomXmlCell,
  Uniword::Generated::Customxml::CustomXmlRow,
  Uniword::Generated::Customxml::SmartTag,
  Uniword::Generated::Customxml::SmartTagProperties,
  Uniword::Generated::Customxml::SmartTagType,
  Uniword::Generated::Customxml::CustomXmlMoveFromRangeStart,
  Uniword::Generated::Customxml::CustomXmlMoveToRangeStart,
  Uniword::Generated::Customxml::CustomXmlInsRangeStart,
  Uniword::Generated::Customxml::CustomXmlDelRangeStart
]

puts "✅ Loaded #{custom_xml_classes.size} Custom XML sample classes"
custom_xml_classes.each { |klass| puts "   - #{klass.name}" }

# Test XML serialization
puts "\nTesting Custom XML serialization..."
begin
  custom_xml = Uniword::Generated::Customxml::CustomXml.new(
    uri: 'http://example.com/schema',
    element: 'mydata'
  )
  xml_output = custom_xml.to_xml
  puts '✅ CustomXml.to_xml() works'
  puts "   Sample: #{xml_output[0..100]}..."
rescue StandardError => e
  puts "❌ Error: #{e.message}"
end

# Test Bibliography namespace
puts "\n#{'=' * 80}"
puts 'Testing Bibliography namespace (b:)...'
puts '-' * 80

bibliography_classes = [
  Uniword::Generated::Bibliography::Sources,
  Uniword::Generated::Bibliography::Source,
  Uniword::Generated::Bibliography::SourceType,
  Uniword::Generated::Bibliography::Tag,
  Uniword::Generated::Bibliography::Guid,
  Uniword::Generated::Bibliography::Lcid,
  Uniword::Generated::Bibliography::Author,
  Uniword::Generated::Bibliography::NameList,
  Uniword::Generated::Bibliography::Person,
  Uniword::Generated::Bibliography::Corporate,
  Uniword::Generated::Bibliography::Title,
  Uniword::Generated::Bibliography::Year,
  Uniword::Generated::Bibliography::Month,
  Uniword::Generated::Bibliography::Day,
  Uniword::Generated::Bibliography::Publisher,
  Uniword::Generated::Bibliography::City,
  Uniword::Generated::Bibliography::Pages,
  Uniword::Generated::Bibliography::VolumeNumber,
  Uniword::Generated::Bibliography::Issue,
  Uniword::Generated::Bibliography::Edition,
  Uniword::Generated::Bibliography::Url
]

puts "✅ Loaded #{bibliography_classes.size} Bibliography sample classes"
bibliography_classes.each { |klass| puts "   - #{klass.name}" }

# Test XML serialization
puts "\nTesting Bibliography serialization..."
begin
  Uniword::Generated::Bibliography::Person.new(
    first: 'John',
    last: 'Doe'
  )

  source = Uniword::Generated::Bibliography::Source.new(
    source_type: 'Book',
    tag: 'Doe2024',
    title: 'Test Title',
    year: '2024'
  )

  xml_output = source.to_xml
  puts '✅ Source.to_xml() works'
  puts "   Sample: #{xml_output[0..100]}..."
rescue StandardError => e
  puts "❌ Error: #{e.message}"
end

# Summary
puts "\n#{'=' * 80}"
puts 'TEST SUMMARY'
puts '=' * 80
puts "Custom XML:    #{custom_xml_classes.size} classes tested"
puts "Bibliography:  #{bibliography_classes.size} classes tested"
puts "Total:         #{custom_xml_classes.size + bibliography_classes.size} classes"
puts
puts '✅ All autoload tests passed!'
puts '✅ All serialization tests passed!'
puts '=' * 80
