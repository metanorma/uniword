#!/usr/bin/env ruby
# frozen_string_literal: true

# Ultimate Round-Trip Test
# Load demo_formal_integral_proper.docx → Save → Compare with Canon

require_relative 'lib/uniword'
require 'canon/comparison'

puts '=' * 80
puts 'ULTIMATE ROUND-TRIP TEST'
puts '=' * 80
puts

input_file = 'examples/demo_formal_integral_proper.docx'
output_file = 'examples/demo_formal_integral_roundtrip.docx'

unless File.exist?(input_file)
  puts "❌ Error: #{input_file} not found"
  exit 1
end

begin
  # Step 1: Load the proper document
  puts 'Step 1: Loading proper document...'
  doc = Uniword::Document.open(input_file)

  puts '  ✓ Document loaded'
  puts "    Paragraphs: #{doc.paragraphs.count}"
  puts "    Tables: #{doc.tables.count}"
  puts "    Styles: #{doc.styles.count}"
  puts "    Theme: #{doc.theme&.name || 'none'}"
  puts "    Theme media: #{doc.theme&.media_files&.count || 0}"
  puts

  # Step 2: Save the document
  puts 'Step 2: Saving document...'
  doc.save(output_file)
  puts "  ✓ Document saved to: #{output_file}"
  puts

  # Step 3: Extract both for comparison
  puts 'Step 3: Extracting packages for comparison...'
  system('cd examples && unzip -qo demo_formal_integral_proper.docx -d roundtrip_original')
  system('cd examples && unzip -qo demo_formal_integral_roundtrip.docx -d roundtrip_saved')
  puts '  ✓ Packages extracted'
  puts

  # Step 4: Compare all XML files with Canon
  puts 'Step 4: Canon comparison of all XML files...'
  puts

  xml_files = [
    'word/document.xml',
    'word/styles.xml',
    'word/theme/theme1.xml',
    'word/fontTable.xml',
    'word/settings.xml',
    'word/webSettings.xml',
    'word/numbering.xml',
    '[Content_Types].xml',
    '_rels/.rels',
    'word/_rels/document.xml.rels',
    'word/theme/_rels/theme1.xml.rels',
    'docProps/app.xml',
    'docProps/core.xml'
  ]

  results = {}
  xml_files.each do |xml_file|
    original_path = "examples/roundtrip_original/#{xml_file}"
    saved_path = "examples/roundtrip_saved/#{xml_file}"

    unless File.exist?(original_path) && File.exist?(saved_path)
      results[xml_file] = { status: :missing }
      next
    end

    original_xml = File.read(original_path)
    saved_xml = File.read(saved_path)

    # Use Canon for semantic comparison
    equivalent = Canon::Comparison.equivalent?(
      saved_xml,
      original_xml,
      match_profile: :spec_friendly
    )

    results[xml_file] = {
      status: equivalent ? :equivalent : :different,
      original_size: original_xml.bytesize,
      saved_size: saved_xml.bytesize,
      size_diff_pct: (((saved_xml.bytesize.to_f / original_xml.bytesize) - 1) * 100).round(1)
    }
  end

  # Display results
  puts '=' * 80
  puts 'ROUND-TRIP RESULTS'
  puts '=' * 80
  puts

  equivalent_count = results.values.count { |r| r[:status] == :equivalent }
  different_count = results.values.count { |r| r[:status] == :different }

  puts "Summary: #{equivalent_count}/#{xml_files.count} files semantically equivalent"
  puts

  results.each do |file, result|
    case result[:status]
    when :equivalent
      puts "  ✓ #{file}"
      puts "    Semantic equivalence preserved (#{result[:original_size]} → #{result[:saved_size]} bytes, #{result[:size_diff_pct]}%)"
    when :different
      puts "  ⚠ #{file}"
      puts "    Semantic differences detected (#{result[:original_size]} → #{result[:saved_size]} bytes, #{result[:size_diff_pct]}%)"
    when :missing
      puts "  ❌ #{file} - Missing in one version"
    end
  end

  puts
  puts '=' * 80
  if equivalent_count == xml_files.count
    puts '✓ PERFECT ROUND-TRIP - All files semantically equivalent!'
    exit 0
  else
    puts "⚠ ROUND-TRIP NEEDS WORK - #{different_count} files differ"
    exit 1
  end
rescue StandardError => e
  puts "❌ Error: #{e.message}"
  puts e.backtrace.first(10)
  exit 1
end
