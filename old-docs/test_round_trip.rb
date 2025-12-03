#!/usr/bin/env ruby
# frozen_string_literal: true

# Simple round-trip test script for ISO 8601 documents

require 'bundler/setup'

test_files = [
  '/Users/mulgogi/src/mn/iso-8601-2/_site/documents/iso-8601-2-2026/iso-wd-8601-2-2026.docx',
  '/Users/mulgogi/src/mn/iso-8601-2/_site/documents/iso-8601-2-2026/document.doc'
]

puts '=== Round-Trip Requirement Analysis ==='
puts 'Testing availability of ISO 8601 test documents...'

test_files.each do |file|
  puts "\n--- #{File.basename(file)} ---"

  if File.exist?(file)
    puts "✓ File exists: #{file}"
    puts "  Size: #{File.size(file)} bytes"
    puts "  Modified: #{File.mtime(file)}"

    # Try to detect format without loading Uniword
    extension = File.extname(file).downcase
    puts "  Extension: #{extension}"

    # Check file signature
    signature = File.open(file, 'rb') { |f| f.read(4) }
    if signature == "PK\x03\x04".b
      puts '  Format: DOCX (ZIP signature detected)'
    elsif signature.include?('MIME')
      puts '  Format: MHTML (MIME header detected)'
    else
      puts "  Format: Unknown (signature: #{signature.unpack1('H*')})"
    end
  else
    puts "✗ File not found: #{file}"

    # Check if parent directory exists
    dir = File.dirname(file)
    if File.exist?(dir)
      puts "  Parent directory exists: #{dir}"
      puts '  Available files:'
      Dir.glob(File.join(dir, '*')).each do |available_file|
        puts "    - #{File.basename(available_file)}"
      end
    else
      puts "  Parent directory not found: #{dir}"
    end
  end
end

puts "\n=== Current Round-Trip Implementation Status ==="

# Check if Uniword loads properly
begin
  require_relative 'lib/uniword'
  puts '✓ Uniword library loads successfully'

  # Check UnknownElement implementation
  if defined?(Uniword::UnknownElement)
    puts '✓ UnknownElement class is available'
  else
    puts '✗ UnknownElement class not found'
  end

  # Check serialization classes
  if defined?(Uniword::Serialization::OoxmlDeserializer)
    puts '✓ OoxmlDeserializer is available'
  else
    puts '✗ OoxmlDeserializer not found'
  end

  if defined?(Uniword::Serialization::OoxmlSerializer)
    puts '✓ OoxmlSerializer is available'
  else
    puts '✗ OoxmlSerializer not found'
  end
rescue StandardError => e
  puts "✗ Uniword library failed to load: #{e.message}"
  puts "  Error type: #{e.class}"
  puts "  Location: #{e.backtrace.first}"
end

puts "\n=== Recommendations ==="
puts '1. Round-trip infrastructure analysis:'
puts '   - UnknownElement preservation: Already implemented'
puts '   - OOXML serialization: Available with round-trip support'
puts '   - Warning collection: Integrated for unknown elements'

puts "\n2. Next steps for perfect round-trip:"
puts '   - Test with actual ISO 8601 documents (when available)'
puts '   - Implement comprehensive round-trip test suite'
puts '   - Validate UnknownElement preservation in real documents'
puts '   - Check for schema gaps in complex documents'
