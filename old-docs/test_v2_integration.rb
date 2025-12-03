#!/usr/bin/env ruby
# frozen_string_literal: true

# Test script to verify v2.0 integration
# Tests: generated classes, extensions, and serialization

$LOAD_PATH.unshift File.expand_path('lib', __dir__)

require 'uniword'

puts '=' * 60
puts 'Phase 3 Integration Test - v2.0 Architecture'
puts '=' * 60
puts

# Test 1: Create document using new API
puts 'Test 1: Create document using Uniword::Document (Generated class)'
doc = Uniword::Document.new
puts '✓ Document.new works'
puts "  Class: #{doc.class}"
puts "  Module chain: #{doc.class.ancestors.take(5).join(' < ')}"
puts

# Test 2: Check extension methods exist
puts 'Test 2: Check extension methods are available'
methods_to_check = %i[add_paragraph add_table text paragraphs save]
methods_to_check.each do |method|
  if doc.respond_to?(method)
    puts "✓ Document##{method} exists"
  else
    puts "✗ Document##{method} MISSING"
  end
end
puts

# Test 3: Add paragraph using extension method
puts 'Test 3: Add paragraph using extension method'
begin
  para = doc.add_paragraph('Hello World', bold: true)
  puts '✓ add_paragraph works'
  puts "  Paragraph class: #{para.class}"
  puts "  Paragraph text: #{para.text}"
rescue StandardError => e
  puts "✗ add_paragraph failed: #{e.message}"
  puts e.backtrace.first(3).join("\n")
end
puts

# Test 4: Add another paragraph with formatting
puts 'Test 4: Add formatted paragraph'
begin
  para2 = doc.add_paragraph('Second paragraph', italic: true, color: 'FF0000')
  puts '✓ Formatted paragraph added'
  puts "  Text: #{para2.text}"
rescue StandardError => e
  puts "✗ Failed: #{e.message}"
end
puts

# Test 5: Test run extensions
puts 'Test 5: Test run extensions'
begin
  para3 = doc.add_paragraph
  para3.add_text('Bold text', bold: true)
  para3.add_text(' normal text')
  para3.add_text(' italic', italic: true)
  puts '✓ Run extensions work'
  puts "  Paragraph text: #{para3.text}"
rescue StandardError => e
  puts "✗ Run extensions failed: #{e.message}"
end
puts

# Test 6: Test paragraph fluent interface
puts 'Test 6: Test paragraph fluent interface'
begin
  para4 = doc.add_paragraph('Centered text')
  para4.align('center').spacing_before(240).spacing_after(240)
  puts '✓ Fluent interface works'
  puts "  Alignment: #{para4.properties&.alignment}"
rescue StandardError => e
  puts "✗ Fluent interface failed: #{e.message}"
end
puts

# Test 7: Test XML serialization
puts 'Test 7: Test XML serialization'
begin
  xml = doc.to_xml
  puts '✓ Serialization works'
  puts "  XML length: #{xml.length} bytes"
  puts '  First 200 chars:'
  puts "  #{xml[0..200].gsub("\n", "\n  ")}"

  # Check for critical elements
  if xml.include?('<w:document')
    puts '✓ Contains <w:document> root'
  else
    puts '✗ Missing <w:document> root'
  end

  if xml.include?('<w:body>')
    puts '✓ Contains <w:body>'
  else
    puts '✗ Missing <w:body>'
  end

  if xml.include?('<w:p>')
    puts '✓ Contains <w:p> (paragraphs)'
  else
    puts '✗ Missing <w:p>'
  end

  if xml.include?('<w:r>')
    puts '✓ Contains <w:r> (runs)'
  else
    puts '✗ Missing <w:r>'
  end
rescue StandardError => e
  puts "✗ Serialization failed: #{e.message}"
  puts e.backtrace.first(5).join("\n")
end
puts

# Test 8: Count document elements
puts 'Test 8: Document structure'
begin
  puts "  Paragraphs: #{doc.paragraphs.length}"
  puts "  Total runs: #{doc.paragraphs.map { |p| p.runs.length }.sum}"
  puts '  Document text preview:'
  puts "  #{doc.text.lines.first(3).join('  ')}"
rescue StandardError => e
  puts "✗ Structure inspection failed: #{e.message}"
end
puts

puts '=' * 60
puts 'Integration test complete!'
puts '=' * 60
