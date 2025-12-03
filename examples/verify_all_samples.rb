#!/usr/bin/env ruby
# frozen_string_literal: true

# Script to verify all 44 Metanorma samples can be converted
#
# This script:
# - Finds all .doc files in the mn-samples-iso directory
# - Tests MHTML→DOCX conversion for each
# - Reports success/failure statistics

require 'bundler/setup'
require 'uniword'
require 'fileutils'

SAMPLES_DIR = '/Users/mulgogi/src/mn/mn-samples-iso/_site'
OUTPUT_DIR = 'tmp/metanorma_verification'

def verify_sample(input_path, output_dir)
  base_name = File.basename(input_path, '.doc')
  output_path = File.join(output_dir, "#{base_name}.docx")

  begin
    # Read MHTML
    doc = Uniword::DocumentFactory.from_file(input_path, format: :mhtml)

    stats = {
      paragraphs: doc.paragraphs.count,
      tables: doc.tables.count,
      text_length: doc.text.length
    }

    # Convert to DOCX
    doc.save(output_path, format: :docx)

    # Verify DOCX was created
    unless File.exist?(output_path)
      return {
        success: false,
        error: 'DOCX file not created',
        stats: stats
      }
    end

    # Read DOCX back to verify
    docx_doc = Uniword::DocumentFactory.from_file(output_path, format: :docx)

    docx_stats = {
      paragraphs: docx_doc.paragraphs.count,
      tables: docx_doc.tables.count,
      text_length: docx_doc.text.length
    }

    # Calculate preservation
    para_preservation = (docx_stats[:paragraphs].to_f / stats[:paragraphs] * 100).round(1)
    text_preservation = (docx_stats[:text_length].to_f / stats[:text_length] * 100).round(1)

    {
      success: true,
      stats: stats,
      docx_stats: docx_stats,
      preservation: {
        paragraphs: para_preservation,
        text: text_preservation,
        tables: stats[:tables] == docx_stats[:tables]
      }
    }
  rescue StandardError => e
    {
      success: false,
      error: e.message,
      backtrace: e.backtrace.first(3)
    }
  end
end

def main
  puts 'Metanorma Sample Verification'
  puts '=' * 80
  puts "Samples directory: #{SAMPLES_DIR}"
  puts "Output directory: #{OUTPUT_DIR}"
  puts

  # Create output directory
  FileUtils.mkdir_p(OUTPUT_DIR)

  # Find all .doc files
  pattern = File.join(SAMPLES_DIR, '**', '*.doc')
  samples = Dir.glob(pattern).sort

  puts "Found #{samples.count} sample files"
  puts '-' * 80
  puts

  results = []

  samples.each_with_index do |sample_path, index|
    relative_path = sample_path.sub("#{SAMPLES_DIR}/", '')
    print "[#{index + 1}/#{samples.count}] #{relative_path}... "

    result = verify_sample(sample_path, OUTPUT_DIR)
    result[:file] = relative_path
    results << result

    if result[:success]
      pres = result[:preservation]
      status = "✅ OK (#{pres[:paragraphs]}% paras, #{pres[:text]}% text)"
      puts status
    else
      puts "❌ FAILED: #{result[:error]}"
    end
  end

  # Print summary
  puts
  puts '=' * 80
  puts 'SUMMARY'
  puts '=' * 80

  successful = results.count { |r| r[:success] }
  failed = results.count { |r| !r[:success] }

  puts "Total samples: #{results.count}"
  puts "Successful: #{successful} (#{(successful.to_f / results.count * 100).round(1)}%)"
  puts "Failed: #{failed}"
  puts

  if successful.positive?
    successful_results = results.select { |r| r[:success] }

    avg_para_pres = successful_results.sum do |r|
      r[:preservation][:paragraphs]
    end / successful_results.count
    avg_text_pres = successful_results.sum do |r|
      r[:preservation][:text]
    end / successful_results.count
    tables_preserved = successful_results.count { |r| r[:preservation][:tables] }

    puts 'Average preservation rates:'
    puts "  Paragraphs: #{avg_para_pres.round(1)}%"
    puts "  Text: #{avg_text_pres.round(1)}%"
    puts "  Tables: #{tables_preserved}/#{successful_results.count} (#{(tables_preserved.to_f / successful_results.count * 100).round(1)}%)"
  end

  if failed.positive?
    puts
    puts 'Failed conversions:'
    results.reject { |r| r[:success] }.each do |r|
      puts "  ❌ #{r[:file]}"
      puts "     Error: #{r[:error]}"
    end
  end

  puts
  puts "Output files saved to: #{OUTPUT_DIR}"
  puts '=' * 80

  # Return exit code
  failed.zero? ? 0 : 1
end

exit main if __FILE__ == $PROGRAM_NAME
