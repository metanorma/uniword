#!/usr/bin/env ruby
# frozen_string_literal: true

require 'bundler/setup'
require_relative 'lib/uniword'
require 'zip'
require 'fileutils'

# Create temp directory
FileUtils.mkdir_p('tmp/debug')

# Load original
original_path = 'spec/fixtures/blank.docx'
puts "Loading: #{original_path}"
doc = Uniword.load(original_path)

# Save
output_path = 'tmp/debug/blank_test.docx'
puts "Saving to: #{output_path}"
doc.save(output_path)

# Extract both and compare document.xml
def extract_file(docx_path, filename)
  Zip::File.open(docx_path) do |zip_file|
    entry = zip_file.find_entry(filename)
    return entry.get_input_stream.read if entry
  end
  nil
end

original_doc_xml = extract_file(original_path, 'word/document.xml')
saved_doc_xml = extract_file(output_path, 'word/document.xml')

puts "\n=== Original word/document.xml ==="
puts original_doc_xml[0..500] if original_doc_xml

puts "\n=== Saved word/document.xml ==="
puts saved_doc_xml[0..500] if saved_doc_xml

# Check for required files
puts "\n=== Checking required files in saved DOCX ==="
required_files = [
  '[Content_Types].xml',
  '_rels/.rels',
  'word/document.xml',
  'word/_rels/document.xml.rels'
]

Zip::File.open(output_path) do |zip_file|
  required_files.each do |filename|
    entry = zip_file.find_entry(filename)
    if entry
      puts "✓ #{filename} (#{entry.size} bytes)"
    else
      puts "✗ #{filename} MISSING"
    end
  end
end

puts "\n=== All files in saved DOCX ==="
Zip::File.open(output_path) do |zip_file|
  zip_file.each do |entry|
    next if entry.directory?

    puts "  #{entry.name} (#{entry.size} bytes)"
  end
end
