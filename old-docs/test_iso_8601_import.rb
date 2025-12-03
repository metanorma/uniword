#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require 'uniword'

files = [
  '/Users/mulgogi/src/mn/iso-8601-2/_site/documents/iso-8601-2-2026/iso-wd-8601-2-2026.docx',
  '/Users/mulgogi/src/mn/iso-8601-2/_site/documents/iso-8601-2-2026/document.doc'
]

puts '=' * 80
puts 'ISO 8601-2 Document Import Test'
puts '=' * 80

files.each do |file|
  puts "\n#{'=' * 80}"
  puts "Testing: #{File.basename(file)}"
  puts '=' * 80

  unless File.exist?(file)
    puts "❌ ERROR: File not found: #{file}"
    next
  end

  begin
    # Test import
    puts "\n📥 Importing document..."
    start_time = Time.now
    doc = Uniword::DocumentFactory.from_file(file)
    import_time = Time.now - start_time
    puts "✅ Import successful (#{import_time.round(2)}s)"

    # Report statistics
    puts "\n📊 Document Statistics:"
    puts "  Paragraphs: #{doc.paragraphs.count}"
    puts "  Tables: #{doc.tables.count}"
    puts "  Images: #{doc.images.count}"
    puts "  Text length: #{doc.text.length} chars"

    # Sample first 500 chars of text
    puts "\n📝 Text Preview (first 500 chars):"
    puts "  #{doc.text[0..500].inspect}"

    # Check for specific features
    puts "\n🔍 Feature Detection:"
    has_numbering = doc.paragraphs.any?(&:num_id)
    has_styles = doc.styles_configuration && !doc.styles_configuration.styles.empty?
    has_headers = doc.sections.any?(&:header)
    has_footers = doc.sections.any?(&:footer)

    puts "  Numbering: #{has_numbering ? '✅ Present' : '❌ None'}"
    puts "  Styles: #{has_styles ? '✅ Present' : '❌ None'}"
    puts "  Headers: #{has_headers ? '✅ Present' : '❌ None'}"
    puts "  Footers: #{has_footers ? '✅ Present' : '❌ None'}"

    # Test round-trip
    output = file.sub(File.extname(file), '_roundtrip.docx')
    puts "\n💾 Testing round-trip..."
    start_time = Time.now
    doc.save(output)
    save_time = Time.now - start_time
    puts "✅ Round-trip saved to: #{output} (#{save_time.round(2)}s)"

    # Re-import and compare
    puts "\n🔄 Verifying round-trip..."
    doc2 = Uniword::DocumentFactory.from_file(output)

    text_match = doc.text == doc2.text
    para_match = doc.paragraphs.count == doc2.paragraphs.count
    table_match = doc.tables.count == doc2.tables.count
    image_match = doc.images.count == doc2.images.count

    puts "  Text preserved: #{text_match ? '✅' : '❌'} (#{doc.text.length} → #{doc2.text.length} chars)"
    puts "  Paragraphs preserved: #{para_match ? '✅' : '❌'} (#{doc.paragraphs.count} → #{doc2.paragraphs.count})"
    puts "  Tables preserved: #{table_match ? '✅' : '❌'} (#{doc.tables.count} → #{doc2.tables.count})"
    puts "  Images preserved: #{image_match ? '✅' : '❌'} (#{doc.images.count} → #{doc2.images.count})"

    # Detailed comparison if there are differences
    unless text_match
      puts "\n⚠️  Text Differences Detected:"
      diff_chars = (doc.text.length - doc2.text.length).abs
      puts "    Character difference: #{diff_chars} chars"

      # Find first difference
      doc.text.chars.each_with_index do |char, i|
        next unless doc2.text[i] != char

        puts "    First difference at position #{i}:"
        puts "      Original: #{doc.text[(i - 20)..(i + 20)].inspect}"
        puts "      Round-trip: #{doc2.text[(i - 20)..(i + 20)].inspect}"
        break
      end
    end
  rescue StandardError => e
    puts "\n❌ ERROR during processing:"
    puts "  #{e.class}: #{e.message}"
    puts "\n  Backtrace (first 10 lines):"
    e.backtrace.first(10).each { |line| puts "    #{line}" }
  end
end

puts "\n#{'=' * 80}"
puts 'Test Complete'
puts '=' * 80
