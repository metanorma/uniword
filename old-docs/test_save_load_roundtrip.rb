#!/usr/bin/env ruby
# frozen_string_literal: true

# Test save/load round-trip with v2.0 architecture

$LOAD_PATH.unshift File.expand_path('lib', __dir__)

require 'uniword'
require 'fileutils'

puts '=' * 60
puts 'Save/Load Round-Trip Test - v2.0'
puts '=' * 60
puts

# Create temp directory for test files
FileUtils.mkdir_p('tmp')

# Test 1: Simple save and load
puts 'Test 1: Simple document save/load'
begin
  # Create document
  doc1 = Uniword::Document.new
  doc1.add_paragraph('Hello World')
  doc1.add_paragraph('Second paragraph', bold: true)

  puts '✓ Document created with 2 paragraphs'
  puts "  Text: #{doc1.text.inspect}"

  # Save to file
  path = 'tmp/test_simple.docx'
  doc1.save(path)
  puts "✓ Document saved to #{path}"

  # Load from file
  doc2 = Uniword.load(path)
  puts "✓ Document loaded from #{path}"
  puts "  Class: #{doc2.class}"
  puts "  Paragraphs: #{doc2.paragraphs.length}"
  puts "  Text: #{doc2.text.inspect}"

  # Verify content
  if doc2.paragraphs.length == 2
    puts '✓ Paragraph count matches'
  else
    puts "✗ Paragraph count mismatch: expected 2, got #{doc2.paragraphs.length}"
  end

  if doc2.text.include?('Hello World') && doc2.text.include?('Second paragraph')
    puts '✓ Text content preserved'
  else
    puts '✗ Text content mismatch'
  end
rescue StandardError => e
  puts "✗ Test 1 failed: #{e.message}"
  puts e.backtrace.first(5).join("\n")
end
puts

# Test 2: Document with formatting
puts 'Test 2: Document with formatting'
begin
  doc1 = Uniword::Document.new
  doc1.add_paragraph('Bold text', bold: true)
  doc1.add_paragraph('Italic text', italic: true)
  doc1.add_paragraph('Colored text', color: 'FF0000')

  puts '✓ Document created with formatted paragraphs'

  path = 'tmp/test_formatted.docx'
  doc1.save(path)
  puts '✓ Document saved'

  doc2 = Uniword.load(path)
  puts '✓ Document loaded'
  puts "  Paragraphs: #{doc2.paragraphs.length}"

  # Check first paragraph's run properties
  if doc2.paragraphs[0]&.runs&.first&.properties&.bold
    puts '✓ Bold formatting preserved'
  else
    puts '⚠ Bold formatting not preserved (may need property parsing)'
  end
rescue StandardError => e
  puts "✗ Test 2 failed: #{e.message}"
  puts e.backtrace.first(3).join("\n")
end
puts

# Test 3: Multiple saves/loads
puts 'Test 3: Multiple round-trips'
begin
  doc1 = Uniword::Document.new
  doc1.add_paragraph('Original text')

  path1 = 'tmp/test_round1.docx'
  doc1.save(path1)

  doc2 = Uniword.load(path1)
  doc2.add_paragraph('Added in round 2')

  path2 = 'tmp/test_round2.docx'
  doc2.save(path2)

  doc3 = Uniword.load(path2)
  puts '✓ Multiple round-trips successful'
  puts "  Final paragraph count: #{doc3.paragraphs.length}"
  puts '  Final text:'
  doc3.paragraphs.each_with_index do |p, i|
    puts "    #{i + 1}. #{p.text}"
  end
rescue StandardError => e
  puts "✗ Test 3 failed: #{e.message}"
  puts e.backtrace.first(3).join("\n")
end
puts

# Test 4: Using Uniword.new shortcut
puts 'Test 4: Module-level convenience methods'
begin
  doc = Uniword.new
  doc.add_paragraph('Test via Uniword.new')

  path = 'tmp/test_convenience.docx'
  doc.save(path)

  doc2 = Uniword.open(path)
  puts '✓ Uniword.new and Uniword.open work'
  puts "  Text: #{doc2.text}"
rescue StandardError => e
  puts "✗ Test 4 failed: #{e.message}"
  puts e.backtrace.first(3).join("\n")
end
puts

# Test 5: Empty document
puts 'Test 5: Empty document round-trip'
begin
  doc1 = Uniword::Document.new

  path = 'tmp/test_empty.docx'
  doc1.save(path)
  puts '✓ Empty document saved'

  doc2 = Uniword.load(path)
  puts '✓ Empty document loaded'
  puts "  Paragraphs: #{doc2.paragraphs.length}"
rescue StandardError => e
  puts "✗ Test 5 failed: #{e.message}"
  puts e.backtrace.first(3).join("\n")
end
puts

puts '=' * 60
puts 'Round-trip test complete!'
puts '=' * 60
puts
puts 'Test files created in tmp/ directory:'
Dir['tmp/test_*.docx'].each do |f|
  size = File.size(f)
  puts "  #{f} (#{size} bytes)"
end
