#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lib/uniword'

# Test the new explicit FormatConverter with ISO 8601-2 documents
puts 'Testing FormatConverter with ISO 8601-2 Documents'
puts '=' * 60

converter = Uniword::FormatConverter.new(logger: Logger.new($stdout))

files = [
  '/Users/mulgogi/src/mn/iso-8601-2/_site/documents/iso-8601-2-2026/iso-wd-8601-2-2026.docx',
  '/Users/mulgogi/src/mn/iso-8601-2/_site/documents/iso-8601-2-2026/document.doc'
]

files.each do |file|
  next unless File.exist?(file)

  puts "\n=== Testing: #{File.basename(file)} ==="
  basename = File.basename(file, File.extname(file))

  # Test 1: DOCX/MHTML to MHTML (explicit)
  if File.extname(file) == '.docx'
    puts "\n1. Explicit DOCX → MHTML conversion:"
    mhtml_output = "#{basename}_converted.mhtml"

    result = converter.docx_to_mhtml(
      source: file,
      target: mhtml_output
    )

    puts result
    puts "  Output: #{mhtml_output}"
    puts "  File size: #{File.size(mhtml_output)} bytes" if File.exist?(mhtml_output)

    # Test 2: MHTML back to DOCX (round-trip)
    puts "\n2. Round-trip: MHTML → DOCX:"
    docx_roundtrip = "#{basename}_roundtrip.docx"

    result2 = converter.mhtml_to_docx(
      source: mhtml_output,
      target: docx_roundtrip
    )

    puts result2
    puts "  Output: #{docx_roundtrip}"

    # Verify text preservation
    original_doc = Uniword::DocumentFactory.from_file(file)
    roundtrip_doc = Uniword::DocumentFactory.from_file(docx_roundtrip)

    text_preserved = original_doc.text == roundtrip_doc.text
    puts "  Text preserved: #{text_preserved}"
    puts "  Original length: #{original_doc.text.length} chars"
    puts "  Roundtrip length: #{roundtrip_doc.text.length} chars"

    unless text_preserved
      diff = original_doc.text.length - roundtrip_doc.text.length
      puts "  Difference: #{diff} chars"
    end

  elsif File.extname(file) == '.doc'
    puts "\n1. Explicit MHTML → DOCX conversion:"
    docx_output = "#{basename}_converted.docx"

    result = converter.mhtml_to_docx(
      source: file,
      target: docx_output
    )

    puts result
    puts "  Output: #{docx_output}"
    puts "  File size: #{File.size(docx_output)} bytes" if File.exist?(docx_output)

    # Test 2: DOCX back to MHTML (round-trip)
    puts "\n2. Round-trip: DOCX → MHTML:"
    mhtml_roundtrip = "#{basename}_roundtrip.mhtml"

    result2 = converter.docx_to_mhtml(
      source: docx_output,
      target: mhtml_roundtrip
    )

    puts result2
    puts "  Output: #{mhtml_roundtrip}"

    # Verify text preservation
    original_doc = Uniword::DocumentFactory.from_file(file, format: :mhtml)
    roundtrip_doc = Uniword::DocumentFactory.from_file(mhtml_roundtrip, format: :mhtml)

    text_preserved = original_doc.text == roundtrip_doc.text
    puts "  Text preserved: #{text_preserved}"
    puts "  Original length: #{original_doc.text.length} chars"
    puts "  Roundtrip length: #{roundtrip_doc.text.length} chars"
  end
end

puts "\n#{'=' * 60}"
puts 'FormatConverter Testing Complete'
puts "\nKey Features Demonstrated:"
puts '✓ Explicit format declaration (no magic)'
puts '✓ Model-to-model transformation'
puts '✓ Declarative API (docx_to_mhtml, mhtml_to_docx)'
puts '✓ Round-trip conversion testing'
puts '✓ Text preservation validation'
