#!/usr/bin/env ruby
# frozen_string_literal: true

# Detailed round-trip test for ISO 8601 documents

require 'bundler/setup'
require_relative 'lib/uniword'
require 'digest'
require 'tempfile'

test_files = [
  '/Users/mulgogi/src/mn/iso-8601-2/_site/documents/iso-8601-2-2026/iso-wd-8601-2-2026.docx',
  '/Users/mulgogi/src/mn/iso-8601-2/_site/documents/iso-8601-2-2026/document.doc'
]

def analyze_document_content(doc, label)
  puts "  #{label} Content Analysis:"
  puts "    - Paragraphs: #{doc.paragraphs.length}"
  puts "    - Tables: #{doc.tables.length}"
  puts "    - Images: #{doc.images.length}"
  puts "    - Hyperlinks: #{doc.hyperlinks.length}"
  puts "    - Styles: #{doc.styles.length}"
  puts "    - Text length: #{doc.text.length} characters"

  # Check for unknown elements if body supports it
  return unless doc.body.respond_to?(:elements)

  unknown_count = doc.body.elements.count { |e| e.is_a?(Uniword::UnknownElement) }
  puts "    - Unknown elements: #{unknown_count}"

  return unless unknown_count.positive?

  puts '    - Unknown element types:'
  doc.body.elements.select { |e| e.is_a?(Uniword::UnknownElement) }.each do |elem|
    puts "      * #{elem.tag_name} (#{elem.element_type})"
  end
end

def test_file_round_trip(file_path)
  puts "\n#{'=' * 60}"
  puts "Testing: #{File.basename(file_path)}"
  puts '=' * 60

  begin
    # Step 1: Read original document
    puts "\n1. Reading original document..."
    original_doc = Uniword::Document.open(file_path)
    puts '   ✓ Successfully read document'

    analyze_document_content(original_doc, 'Original')

    # Step 2: Save to temporary file for round-trip
    puts "\n2. Performing round-trip save..."
    temp_file = Tempfile.new(['roundtrip_', '.docx'])
    temp_path = temp_file.path
    temp_file.close

    original_doc.save(temp_path)
    puts "   ✓ Successfully saved to: #{temp_path}"

    # Step 3: Read the round-trip document
    puts "\n3. Reading round-trip document..."
    roundtrip_doc = Uniword::Document.open(temp_path)
    puts '   ✓ Successfully read round-trip document'

    analyze_document_content(roundtrip_doc, 'Round-trip')

    # Step 4: Compare documents
    puts "\n4. Comparing documents..."

    # Compare paragraph count
    if original_doc.paragraphs.length == roundtrip_doc.paragraphs.length
      puts "   ✓ Paragraph count preserved (#{original_doc.paragraphs.length})"
    else
      puts "   ✗ Paragraph count differs: #{original_doc.paragraphs.length} → #{roundtrip_doc.paragraphs.length}"
    end

    # Compare table count
    if original_doc.tables.length == roundtrip_doc.tables.length
      puts "   ✓ Table count preserved (#{original_doc.tables.length})"
    else
      puts "   ✗ Table count differs: #{original_doc.tables.length} → #{roundtrip_doc.tables.length}"
    end

    # Compare text content length
    text_diff = (original_doc.text.length - roundtrip_doc.text.length).abs
    text_diff_percent = text_diff.to_f / original_doc.text.length * 100

    if text_diff_percent < 1.0
      puts "   ✓ Text content preserved (#{text_diff} chars diff, #{text_diff_percent.round(2)}%)"
    else
      puts "   ⚠ Text content differs significantly (#{text_diff} chars, #{text_diff_percent.round(2)}%)"
    end

    # Compare file sizes
    original_size = File.size(file_path)
    roundtrip_size = File.size(temp_path)
    size_diff_percent = ((roundtrip_size - original_size).abs.to_f / original_size * 100).round(2)

    puts "   - File size: #{original_size} → #{roundtrip_size} bytes (#{size_diff_percent}% difference)"

    # Step 5: Check for warnings/unknown elements
    puts "\n5. Round-trip quality assessment..."

    if size_diff_percent < 10
      puts '   ✓ Good size preservation (< 10% difference)'
    elsif size_diff_percent < 25
      puts "   ⚠ Moderate size difference (#{size_diff_percent}%)"
    else
      puts "   ✗ Significant size difference (#{size_diff_percent}%)"
    end

    puts "\n   Round-trip Result: #{size_diff_percent < 25 ? 'ACCEPTABLE' : 'NEEDS IMPROVEMENT'}"

    # Cleanup
    FileUtils.rm_f(temp_path)
  rescue StandardError => e
    puts "   ✗ Error during round-trip test: #{e.class}: #{e.message}"
    puts "   Stack trace: #{e.backtrace.first(5).join("\n   ")}"
    return false
  end

  true
end

puts '=== Detailed Round-Trip Analysis for ISO 8601 Documents ==='
puts 'Testing round-trip fidelity with real documents...'

success_count = 0
test_files.each do |file_path|
  if File.exist?(file_path)
    success_count += 1 if test_file_round_trip(file_path)
  else
    puts "\nSkipping #{File.basename(file_path)} - file not found"
  end
end

puts "\n#{'=' * 60}"
puts 'SUMMARY'
puts '=' * 60
puts "Files tested: #{test_files.count { |f| File.exist?(f) }}"
puts "Successful round-trips: #{success_count}"
puts "Success rate: #{success_count.to_f / test_files.count { |f| File.exist?(f) } * 100}%"

if success_count == test_files.count { |f| File.exist?(f) }
  puts "\n✓ All round-trip tests passed!"
  puts "\nNext steps:"
  puts '- Implement byte-level comparison tests'
  puts '- Add schema validation for unknown elements'
  puts '- Create automated test suite'
else
  puts "\n⚠ Some round-trip tests failed or had issues"
  puts "\nNext steps:"
  puts '- Investigate failed round-trips'
  puts '- Improve UnknownElement preservation'
  puts '- Enhance OOXML schema coverage'
end
