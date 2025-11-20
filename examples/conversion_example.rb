#!/usr/bin/env ruby
# frozen_string_literal: true

# Conversion example for Uniword
# Demonstrates converting documents between formats

require 'bundler/setup'
require 'uniword'

puts 'Document Conversion Example'
puts '=' * 50

# Create a sample document
puts "\n1. Creating a sample document..."
doc = Uniword::Builder.new
  .add_heading('Document Conversion', level: 1)
  .add_paragraph('This document demonstrates format conversion capabilities.')
  .add_blank_line
  .add_heading('Features', level: 2)
  .add_paragraph('Uniword can convert between different document formats:', bold: false)
  .add_paragraph('• DOCX (Office Open XML)', bold: false)
  .add_paragraph('• MHTML (MIME HTML)', bold: false)
  .add_blank_line
  .add_table do
    row do
      cell 'Format', bold: true
      cell 'Extension', bold: true
      cell 'Description', bold: true
    end
    row do
      cell 'DOCX'
      cell '.docx'
      cell 'Modern Word format'
    end
    row do
      cell 'MHTML'
      cell '.mhtml, .mht'
      cell 'Web archive format'
    end
  end
  .build

output_dir = File.join(__dir__, 'output')
Dir.mkdir(output_dir) unless Dir.exist?(output_dir)

# Save as DOCX
docx_path = File.join(output_dir, 'conversion_source.docx')
doc.save(docx_path, format: :docx)
puts "✓ Created DOCX: #{docx_path}"

# Convert DOCX to MHTML
puts "\n2. Converting DOCX to MHTML..."
doc_from_docx = Uniword::Document.open(docx_path)
mhtml_path = File.join(output_dir, 'conversion_output.mhtml')
doc_from_docx.save(mhtml_path, format: :mhtml)
puts "✓ Converted to MHTML: #{mhtml_path}"

# Convert MHTML back to DOCX
puts "\n3. Converting MHTML back to DOCX..."
doc_from_mhtml = Uniword::Document.open(mhtml_path)
docx_roundtrip_path = File.join(output_dir, 'conversion_roundtrip.docx')
doc_from_mhtml.save(docx_roundtrip_path, format: :docx)
puts "✓ Converted back to DOCX: #{docx_roundtrip_path}"

# Display statistics
puts "\n4. Conversion Statistics:"
puts "   Original DOCX:"
puts "     - Paragraphs: #{doc.paragraphs.count}"
puts "     - Tables: #{doc.tables.count}"
puts "     - File size: #{File.size(docx_path)} bytes"

puts "\n   Converted MHTML:"
puts "     - Paragraphs: #{doc_from_docx.paragraphs.count}"
puts "     - Tables: #{doc_from_docx.tables.count}"
puts "     - File size: #{File.size(mhtml_path)} bytes"

puts "\n   Roundtrip DOCX:"
puts "     - Paragraphs: #{doc_from_mhtml.paragraphs.count}"
puts "     - Tables: #{doc_from_mhtml.tables.count}"
puts "     - File size: #{File.size(docx_roundtrip_path)} bytes"

puts "\n5. Format Detection:"
detector = Uniword::FormatDetector.new
[docx_path, mhtml_path, docx_roundtrip_path].each do |path|
  format = detector.detect(path)
  puts "   #{File.basename(path)}: #{format.to_s.upcase}"
end

puts "\n" + "=" * 50
puts "Conversion example complete!"
puts "\nAll files saved to: #{output_dir}"
puts "\nYou can also use the CLI for conversions:"
puts "  $ uniword convert input.docx output.mhtml"
puts "  $ uniword convert input.mhtml output.docx --verbose"