#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lib/uniword'

puts "\n=== Minimal Deserialization Test ===\n\n"

# Test 1: Create minimal XML directly
minimal_xml = <<~XML
  <?xml version="1.0" encoding="UTF-8"?>
  <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
    <w:body>
      <w:p>
        <w:r>
          <w:t>Hello World</w:t>
        </w:r>
      </w:p>
    </w:body>
  </w:document>
XML

puts 'Test 1: Deserialize minimal XML'
puts 'XML:'
puts minimal_xml
puts

begin
  doc = Uniword::Document.from_xml(minimal_xml)
  puts '✅ Document deserialized'
  puts "Body class: #{doc.body.class}"
  puts "Body paragraphs: #{doc.body.paragraphs.inspect}"
  puts "Paragraph count: #{doc.body.paragraphs.size}"

  if doc.body.paragraphs.empty?
    puts '❌ ERROR: Paragraphs array is empty!'
  else
    puts "✅ Paragraphs found: #{doc.body.paragraphs.size}"
    para = doc.body.paragraphs.first
    puts "  First paragraph class: #{para.class}"
    puts "  First paragraph text: #{para.text}" if para.respond_to?(:text)
  end
rescue StandardError => e
  puts "❌ ERROR: #{e.class}: #{e.message}"
  puts e.backtrace.first(5)
end

puts "\n#{'=' * 50}\n\n"

# Test 2: Test Body deserialization directly
body_xml = <<~XML
  <w:body xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
    <w:p>
      <w:r>
        <w:t>Test paragraph</w:t>
      </w:r>
    </w:p>
  </w:body>
XML

puts 'Test 2: Deserialize Body XML directly'
puts 'XML:'
puts body_xml
puts

begin
  body = Uniword::Body.from_xml(body_xml)
  puts '✅ Body deserialized'
  puts "Paragraphs: #{body.paragraphs.inspect}"
  puts "Paragraph count: #{body.paragraphs.size}"

  if body.paragraphs.empty?
    puts '❌ ERROR: Paragraphs array is empty!'
  else
    puts "✅ Paragraphs found: #{body.paragraphs.size}"
  end
rescue StandardError => e
  puts "❌ ERROR: #{e.class}: #{e.message}"
  puts e.backtrace.first(5)
end

puts "\n#{'=' * 50}\n\n"

# Test 3: Test Paragraph deserialization directly
para_xml = <<~XML
  <w:p xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
    <w:r>
      <w:t>Paragraph text</w:t>
    </w:r>
  </w:p>
XML

puts 'Test 3: Deserialize Paragraph XML directly'
puts 'XML:'
puts para_xml
puts

begin
  para = Uniword::Paragraph.from_xml(para_xml)
  puts '✅ Paragraph deserialized'
  puts "Runs: #{para.runs.inspect}"
  puts "Run count: #{para.runs.size}"
  puts "Text: #{para.text}" if para.respond_to?(:text)

  if para.runs.empty?
    puts '❌ ERROR: Runs array is empty!'
  else
    puts "✅ Runs found: #{para.runs.size}"
  end
rescue StandardError => e
  puts "❌ ERROR: #{e.class}: #{e.message}"
  puts e.backtrace.first(5)
end
