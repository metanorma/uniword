#!/usr/bin/env ruby
# frozen_string_literal: true

# Add canon to load path
$LOAD_PATH.unshift('/Users/mulgogi/src/lutaml/canon/lib')

require 'canon/comparison'
require 'tempfile'
require 'zip'

# Extract styles.xml from a .docx file
def extract_styles_xml(docx_path)
  Zip::File.open(docx_path) do |zip_file|
    entry = zip_file.find_entry('word/styles.xml')
    return entry.get_input_stream.read if entry
  end
  nil
end

# Compare styles.xml from two documents
def compare_styles(generated_path, proper_path)
  puts 'Comparing styles.xml files...'
  puts "Generated: #{generated_path}"
  puts "Proper:    #{proper_path}"
  puts '=' * 80

  # Extract styles.xml from both documents
  generated_xml = extract_styles_xml(generated_path)
  proper_xml = extract_styles_xml(proper_path)

  unless generated_xml && proper_xml
    puts 'ERROR: Could not extract styles.xml from one or both documents'
    exit 1
  end

  # Use Canon for semantic comparison
  result = Canon::Comparison.equivalent?(
    generated_xml,
    proper_xml,
    verbose: true
  )

  if result.equivalent?
    puts "\n✓ Styles.xml files are semantically EQUIVALENT"
    true
  else
    puts "\n✗ Styles.xml files are DIFFERENT"
    puts "\nSemantic differences:"
    puts result.message if result.respond_to?(:message)
    puts result.inspect

    # Save XML files for manual inspection
    File.write('/tmp/generated_styles.xml', generated_xml)
    File.write('/tmp/proper_styles.xml', proper_xml)
    puts "\nXML files saved for inspection:"
    puts '  Generated: /tmp/generated_styles.xml'
    puts '  Proper:    /tmp/proper_styles.xml'

    # Show basic diff using unix diff
    puts "\nRunning basic diff (first 100 lines):"
    system('diff -u /tmp/proper_styles.xml /tmp/generated_styles.xml | head -100')

    false
  end
end

# Main
if ARGV.length < 2
  puts "Usage: #{$PROGRAM_NAME} <generated.docx> <proper.docx>"
  exit 1
end

generated_path = ARGV[0]
proper_path = ARGV[1]

unless File.exist?(generated_path) && File.exist?(proper_path)
  puts 'ERROR: One or both files do not exist'
  exit 1
end

success = compare_styles(generated_path, proper_path)
exit(success ? 0 : 1)
