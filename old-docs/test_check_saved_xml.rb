#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lib/uniword'
require 'zip'

puts "\n=== Check Saved DOCX XML ===\n\n"

# Create and save a simple document
doc = Uniword::Document.new
doc.add_paragraph('Test paragraph 1')
doc.add_paragraph('Test paragraph 2')

output_path = 'test_output/check_xml.docx'
doc.save(output_path)
puts "✅ Document saved to #{output_path}"

# Extract and check the document.xml
Zip::File.open(output_path) do |zip_file|
  doc_xml_entry = zip_file.find_entry('word/document.xml')
  if doc_xml_entry
    xml_content = doc_xml_entry.get_input_stream.read
    puts "\n📄 word/document.xml content:"
    puts '=' * 60
    puts xml_content
    puts '=' * 60
  else
    puts '❌ ERROR: word/document.xml not found in ZIP!'
  end
end

# Now try to load it back
puts "\n\nLoading document back..."
loaded_doc = Uniword::Document.open(output_path)
puts "Body paragraphs: #{loaded_doc.body.paragraphs.size}"
puts "Paragraphs found: #{loaded_doc.body.paragraphs.inspect}"
