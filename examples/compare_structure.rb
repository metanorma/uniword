#!/usr/bin/env ruby
# frozen_string_literal: true

require 'English'
require 'zip'
require 'nokogiri'
require 'fileutils'

# Extract and pretty-format document.xml from a DOCX file
def extract_and_format_document_xml(docx_path, output_path)
  Zip::File.open(docx_path) do |zip_file|
    entry = zip_file.find_entry('word/document.xml')
    raise "No document.xml found in #{docx_path}" unless entry

    xml_content = entry.get_input_stream.read
    doc = Nokogiri::XML(xml_content)

    # Pretty format with 2-space indentation
    formatted_xml = doc.to_xml(indent: 2)

    File.write(output_path, formatted_xml)
    puts "Extracted and formatted: #{output_path}"
  end
end

# Main execution
puts '=' * 70
puts 'Document Structure Comparison'
puts '=' * 70

reference_docx = 'examples/demo_formal_integral_proper.docx'
generated_docx = 'examples/demo_formal_integral_structure_match.docx'

output_dir = 'examples/structure_comparison'
FileUtils.mkdir_p(output_dir)

reference_xml = File.join(output_dir, 'reference_document.xml')
generated_xml = File.join(output_dir, 'generated_document.xml')
diff_output = File.join(output_dir, 'structure_diff.txt')

puts "\nExtracting XML from documents..."
extract_and_format_document_xml(reference_docx, reference_xml)
extract_and_format_document_xml(generated_docx, generated_xml)

puts "\nRunning diff comparison..."
`diff -u "#{reference_xml}" "#{generated_xml}" > "#{diff_output}" 2>&1`
exit_code = $CHILD_STATUS.exitstatus

puts "\nComparison Results:"
puts '-' * 70

if exit_code.zero?
  puts '✅ PERFECT MATCH - Documents have identical structure!'
  File.write(diff_output, "No differences found - documents are structurally identical.\n")
elsif exit_code == 1
  diff_content = File.read(diff_output)
  line_count = diff_content.lines.count

  puts "⚠️  DIFFERENCES FOUND - #{line_count} lines of differences"
  puts "\nDiff saved to: #{diff_output}"
  puts "\nFirst 50 lines of diff:"
  puts '-' * 70
  puts diff_content.lines.first(50).join
  puts '-' * 70
  puts "(See #{diff_output} for full diff)"
else
  puts "❌ ERROR - Diff command failed with exit code #{exit_code}"
end

puts "\nGenerated files:"
puts "  Reference XML: #{reference_xml}"
puts "  Generated XML: #{generated_xml}"
puts "  Diff output:   #{diff_output}"
puts '=' * 70
