#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lib/uniword'

puts "\n=== Test Document Serialization ===\n\n"

# Create document with paragraphs
doc = Uniword::Document.new
puts 'Creating document with 2 paragraphs...'
doc.add_paragraph('Paragraph 1')
doc.add_paragraph('Paragraph 2')

puts "Document body paragraphs: #{doc.body.paragraphs.size}"
puts "Paragraphs: #{doc.body.paragraphs.map(&:text)}"

# Serialize to XML
puts "\n📤 Serializing document to XML..."
xml = doc.to_xml(encoding: 'UTF-8')

puts "\n📄 Generated XML:"
puts '=' * 60
puts xml
puts '=' * 60

# Check if body is in XML
if xml.include?('<w:body') || xml.include?('<body')
  puts "\n✅ Body element found in XML"
else
  puts "\n❌ ERROR: Body element NOT found in XML!"
end

# Check if paragraphs are in XML
if xml.include?('<w:p') || xml.include?('<p')
  puts '✅ Paragraph elements found in XML'
else
  puts '❌ ERROR: Paragraph elements NOT found in XML!'
end
