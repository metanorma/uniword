#!/usr/bin/env ruby
# frozen_string_literal: true

# Quick test to verify XML deserialization works in v2.0

$LOAD_PATH.unshift File.expand_path('lib', __dir__)

require 'uniword'

puts '=' * 60
puts 'Deserialization Test - v2.0'
puts '=' * 60
puts

# Test 1: Simple XML deserialization
puts 'Test 1: Deserialize minimal document'
begin
  xml = <<~XML
    <?xml version="1.0" encoding="UTF-8"?>
    <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
      <w:body>
        <w:p>
          <w:r>
            <w:t>Test paragraph</w:t>
          </w:r>
        </w:p>
      </w:body>
    </w:document>
  XML

  doc = Uniword::Generated::Wordprocessingml::DocumentRoot.from_xml(xml)
  puts '✓ Parsed successfully'
  puts "  Document class: #{doc.class}"
  puts "  Body present: #{!doc.body.nil?}"
  puts "  Paragraphs count: #{doc.body&.paragraphs&.length || 0}"

  if doc.body&.paragraphs&.any?
    para = doc.body.paragraphs.first
    puts "  First paragraph runs: #{para.runs&.length || 0}"
    if para.runs&.any?
      run = para.runs.first
      puts "  First run text: #{run.text.inspect}"
    end
  end
rescue StandardError => e
  puts "✗ Deserialization failed: #{e.message}"
  puts e.backtrace.first(5).join("\n")
end
puts

# Test 2: Document with formatting
puts 'Test 2: Deserialize document with formatting'
begin
  xml = <<~XML
    <?xml version="1.0" encoding="UTF-8"?>
    <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
      <w:body>
        <w:p>
          <w:pPr>
            <w:jc w:val="center"/>
          </w:pPr>
          <w:r>
            <w:rPr>
              <w:b/>
              <w:color w:val="FF0000"/>
            </w:rPr>
            <w:t>Bold red text</w:t>
          </w:r>
        </w:p>
      </w:body>
    </w:document>
  XML

  doc = Uniword::Generated::Wordprocessingml::DocumentRoot.from_xml(xml)
  puts '✓ Parsed with formatting'

  para = doc.body.paragraphs.first
  puts "  Paragraph alignment: #{para.properties&.alignment || 'none'}"

  run = para.runs.first
  puts "  Run bold: #{run.properties&.bold || false}"
  puts "  Run color: #{run.properties&.color || 'none'}"
  puts "  Run text: #{run.text}"
rescue StandardError => e
  puts "✗ Failed: #{e.message}"
  puts e.backtrace.first(3).join("\n")
end
puts

# Test 3: Multiple paragraphs
puts 'Test 3: Multiple paragraphs'
begin
  xml = <<~XML
    <?xml version="1.0" encoding="UTF-8"?>
    <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
      <w:body>
        <w:p>
          <w:r><w:t>First paragraph</w:t></w:r>
        </w:p>
        <w:p>
          <w:r><w:t>Second paragraph</w:t></w:r>
        </w:p>
        <w:p>
          <w:r><w:t>Third paragraph</w:t></w:r>
        </w:p>
      </w:body>
    </w:document>
  XML

  doc = Uniword::Generated::Wordprocessingml::DocumentRoot.from_xml(xml)
  puts '✓ Parsed multiple paragraphs'
  puts "  Paragraph count: #{doc.body.paragraphs.length}"
  puts '  Extracted text:'
  doc.body.paragraphs.each_with_index do |p, i|
    puts "    #{i + 1}. #{p.text}"
  end
rescue StandardError => e
  puts "✗ Failed: #{e.message}"
end
puts

# Test 4: Test text extraction convenience method
puts 'Test 4: Test text extraction'
begin
  xml = <<~XML
    <?xml version="1.0" encoding="UTF-8"?>
    <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
      <w:body>
        <w:p>
          <w:r><w:t>Line 1</w:t></w:r>
        </w:p>
        <w:p>
          <w:r><w:t>Line 2</w:t></w:r>
        </w:p>
      </w:body>
    </w:document>
  XML

  doc = Uniword::Generated::Wordprocessingml::DocumentRoot.from_xml(xml)
  text = doc.text
  puts '✓ Text extraction works'
  puts "  Full text: #{text.inspect}"
  puts "  Contains 'Line 1': #{text.include?('Line 1')}"
  puts "  Contains 'Line 2': #{text.include?('Line 2')}"
rescue StandardError => e
  puts "✗ Failed: #{e.message}"
end
puts

puts '=' * 60
puts 'Deserialization test complete!'
puts '=' * 60
