#!/usr/bin/env ruby
# frozen_string_literal: true

# Example: Converting Metanorma documents between formats
#
# This example demonstrates:
# - Converting MHTML to DOCX
# - Round-trip conversion
# - Quality verification

require 'bundler/setup'
require 'uniword'

# Example 1: Basic MHTML to DOCX conversion
def example_basic_conversion
  puts "\n=== Example 1: Basic MHTML to DOCX Conversion ==="

  # Assuming you have a Metanorma-generated .doc file
  input_file = 'metanorma_output.doc'
  output_file = 'converted_output.docx'

  # Read MHTML document
  doc = Uniword::DocumentFactory.from_file(input_file, format: :mhtml)

  puts 'Loaded document:'
  puts "  Paragraphs: #{doc.paragraphs.count}"
  puts "  Tables: #{doc.tables.count}"
  puts "  Text length: #{doc.text.length} characters"

  # Save as DOCX
  doc.save(output_file, format: :docx)

  puts "Converted to #{output_file}"
  puts "  File size: #{File.size(output_file)} bytes"
rescue Errno::ENOENT
  puts '⚠️  File not found. Please provide a valid Metanorma .doc file'
end

# Example 2: Batch conversion
def example_batch_conversion
  puts "\n=== Example 2: Batch Conversion ==="

  # Convert all .doc files in a directory
  pattern = 'metanorma_output/**/*.doc'
  files = Dir.glob(pattern)

  if files.empty?
    puts "No .doc files found matching: #{pattern}"
    return
  end

  results = []

  files.each do |input_path|
    output_path = input_path.sub('.doc', '.docx')

    begin
      doc = Uniword::DocumentFactory.from_file(input_path)
      doc.save(output_path)

      results << {
        file: File.basename(input_path),
        status: '✅',
        paragraphs: doc.paragraphs.count,
        tables: doc.tables.count
      }
    rescue StandardError => e
      results << {
        file: File.basename(input_path),
        status: '❌',
        error: e.message
      }
    end
  end

  # Print summary
  puts "\nConversion Results:"
  puts '-' * 60
  results.each do |r|
    if r[:status] == '✅'
      puts "#{r[:status]} #{r[:file]}: #{r[:paragraphs]} paras, #{r[:tables]} tables"
    else
      puts "#{r[:status]} #{r[:file]}: #{r[:error]}"
    end
  end
end

# Example 3: Round-trip conversion with verification
def example_roundtrip_conversion
  puts "\n=== Example 3: Round-trip Conversion with Verification ==="

  input_file = 'metanorma_output.doc'

  begin
    # Read original MHTML
    original = Uniword::DocumentFactory.from_file(input_file, format: :mhtml)
    original_stats = {
      paragraphs: original.paragraphs.count,
      tables: original.tables.count,
      text_length: original.text.length
    }

    puts 'Original document:'
    puts "  Paragraphs: #{original_stats[:paragraphs]}"
    puts "  Tables: #{original_stats[:tables]}"
    puts "  Text length: #{original_stats[:text_length]}"

    # Convert to DOCX
    temp_docx = 'temp_roundtrip.docx'
    original.save(temp_docx, format: :docx)

    # Read DOCX back
    docx_doc = Uniword::DocumentFactory.from_file(temp_docx, format: :docx)

    # Convert back to MHTML
    temp_doc = 'temp_roundtrip.doc'
    docx_doc.save(temp_doc, format: :mhtml)

    # Read final MHTML
    final = Uniword::DocumentFactory.from_file(temp_doc, format: :mhtml)
    final_stats = {
      paragraphs: final.paragraphs.count,
      tables: final.tables.count,
      text_length: final.text.length
    }

    puts "\nAfter round-trip:"
    puts "  Paragraphs: #{final_stats[:paragraphs]}"
    puts "  Tables: #{final_stats[:tables]}"
    puts "  Text length: #{final_stats[:text_length]}"

    # Calculate preservation rates
    para_preservation = (final_stats[:paragraphs].to_f / original_stats[:paragraphs] * 100).round(1)
    text_preservation = (final_stats[:text_length].to_f / original_stats[:text_length] * 100).round(1)
    tables_preserved = final_stats[:tables] == original_stats[:tables]

    puts "\nPreservation rates:"
    puts "  Paragraphs: #{para_preservation}%"
    puts "  Text: #{text_preservation}%"
    puts "  Tables: #{tables_preserved ? '✅ Preserved' : '❌ Lost'}"

    # Cleanup
    FileUtils.rm_f(temp_docx)
    FileUtils.rm_f(temp_doc)
  rescue Errno::ENOENT
    puts '⚠️  File not found. Please provide a valid Metanorma .doc file'
  end
end

# Example 4: Quality assurance check
def example_quality_check
  puts "\n=== Example 4: Quality Assurance Check ==="

  input_file = 'metanorma_output.doc'

  begin
    # Read document
    doc = Uniword::DocumentFactory.from_file(input_file, format: :mhtml)

    # Perform quality checks
    checks = {
      'Has paragraphs' => doc.paragraphs.any?,
      'Has tables' => doc.tables.any?,
      'Has text content' => doc.text.length > 100,
      'Has styles' => doc.styles_configuration.all_styles.any?
    }

    puts 'Quality checks:'
    checks.each do |check, result|
      status = result ? '✅' : '❌'
      puts "  #{status} #{check}"
    end

    # Check for formatted content
    bold_count = 0
    doc.paragraphs.each do |para|
      para.runs.each do |run|
        bold_count += 1 if run.properties&.bold
      end
    end

    puts "\nFormatting analysis:"
    puts "  Bold runs: #{bold_count}"
    puts "  Average runs per paragraph: #{(doc.paragraphs.sum do |p|
      p.runs.count
    end.to_f / doc.paragraphs.count).round(1)}"
  rescue Errno::ENOENT
    puts '⚠️  File not found. Please provide a valid Metanorma .doc file'
  end
end

# Example 5: Extract and analyze content
def example_content_analysis
  puts "\n=== Example 5: Content Analysis ==="

  input_file = 'metanorma_output.doc'

  begin
    doc = Uniword::DocumentFactory.from_file(input_file, format: :mhtml)

    # Analyze paragraphs
    heading_count = 0
    normal_count = 0
    list_count = 0

    doc.paragraphs.each do |para|
      style = para.properties&.style || 'Normal'
      case style
      when /Heading/
        heading_count += 1
      when /List/
        list_count += 1
      else
        normal_count += 1
      end
    end

    puts 'Paragraph analysis:'
    puts "  Headings: #{heading_count}"
    puts "  Normal: #{normal_count}"
    puts "  Lists: #{list_count}"

    # Analyze tables
    if doc.tables.any?
      puts "\nTable analysis:"
      doc.tables.each_with_index do |table, i|
        row_count = table.rows.count
        col_count = table.rows.first&.cells&.count || 0
        puts "  Table #{i + 1}: #{row_count} rows × #{col_count} columns"
      end
    end
  rescue Errno::ENOENT
    puts '⚠️  File not found. Please provide a valid Metanorma .doc file'
  end
end

# Run all examples
if __FILE__ == $PROGRAM_NAME
  puts 'Metanorma Conversion Examples'
  puts '=' * 60

  # Uncomment the examples you want to run:
  example_basic_conversion
  # example_batch_conversion
  # example_roundtrip_conversion
  # example_quality_check
  # example_content_analysis

  puts "\n#{'=' * 60}"
  puts 'Examples complete!'
end
