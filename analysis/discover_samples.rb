#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'

# Script to discover and catalog DOC files in mn-samples-iso
samples_dir = '/Users/mulgogi/src/mn/mn-samples-iso/_site'
output_file = 'analysis/mn_samples_analysis.md'

# Find all .doc files
doc_files = Dir.glob(File.join(samples_dir, '**/*.doc')).sort

puts "Found #{doc_files.count} DOC files"

# Analyze each file
results = []

doc_files.each_with_index do |doc_path, idx|
  print "\rAnalyzing #{idx + 1}/#{doc_files.count}..."

  begin
    size = File.size(doc_path)

    # Read first 1000 bytes to detect format
    content = File.binread(doc_path, 1000)

    format = if content.include?('MIME-Version')
               'MHTML'
             elsif content.start_with?('PK')
               'DOCX (ZIP-based)'
             elsif content.start_with?("\xD0\xCF\x11\xE0") # OLE2 signature
               'DOC (Binary OLE2)'
             else
               'Unknown'
             end

    # Extract relative path for display
    rel_path = doc_path.sub("#{samples_dir}/", '')

    results << {
      path: rel_path,
      full_path: doc_path,
      size: size,
      format: format
    }
  rescue StandardError => e
    puts "\nError analyzing #{doc_path}: #{e.message}"
  end
end

puts "\n\nGenerating report..."

# Generate markdown report
File.open(output_file, 'w') do |f|
  f.puts '# Metanorma ISO Samples - DOC File Analysis'
  f.puts
  f.puts "**Analysis Date**: #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
  f.puts "**Total Files Found**: #{results.count}"
  f.puts
  f.puts '## Summary Statistics'
  f.puts

  # Format distribution
  format_counts = results.group_by { |r| r[:format] }.transform_values(&:count)
  f.puts '### Format Distribution'
  f.puts
  format_counts.each do |format, count|
    f.puts "- **#{format}**: #{count} files"
  end
  f.puts

  # Size statistics
  sizes = results.map { |r| r[:size] }
  total_size = sizes.sum
  avg_size = sizes.sum / sizes.count
  min_size = sizes.min
  max_size = sizes.max

  f.puts '### Size Statistics'
  f.puts
  f.puts "- **Total Size**: #{(total_size / 1024.0 / 1024.0).round(2)} MB"
  f.puts "- **Average Size**: #{(avg_size / 1024.0).round(2)} KB"
  f.puts "- **Min Size**: #{(min_size / 1024.0).round(2)} KB"
  f.puts "- **Max Size**: #{(max_size / 1024.0 / 1024.0).round(2)} MB"
  f.puts

  # Document types from paths
  doc_types = results.map { |r| r[:path].split('/')[1] }.compact.uniq.sort
  f.puts '### Document Types Found'
  f.puts
  doc_types.each do |type|
    count = results.count { |r| r[:path].include?("/#{type}/") }
    f.puts "- **#{type}**: #{count} files"
  end
  f.puts

  # Detailed file listing
  f.puts '## Detailed File Listing'
  f.puts
  f.puts '| # | Path | Format | Size (KB) |'
  f.puts '|---|------|--------|-----------|'

  results.each_with_index do |result, idx|
    size_kb = (result[:size] / 1024.0).round(2)
    f.puts "| #{idx + 1} | `#{result[:path]}` | #{result[:format]} | #{size_kb} |"
  end
  f.puts

  # Group by format
  f.puts '## Files Grouped by Format'
  f.puts

  format_counts.keys.sort.each do |format|
    f.puts "### #{format}"
    f.puts
    format_results = results.select { |r| r[:format] == format }
    format_results.each do |result|
      size_kb = (result[:size] / 1024.0).round(2)
      f.puts "- `#{result[:path]}` (#{size_kb} KB)"
    end
    f.puts
  end

  # Sample files for testing (pick representative samples)
  f.puts '## Recommended Test Files'
  f.puts
  f.puts 'Based on the analysis, here are recommended files for testing:'
  f.puts

  # Pick smallest MHTML file
  if format_counts.key?('MHTML')
    smallest_mhtml = results.select { |r| r[:format] == 'MHTML' }.min_by { |r| r[:size] }
    f.puts '### Smallest MHTML File (Good starting point)'
    f.puts "- Path: `#{smallest_mhtml[:path]}`"
    f.puts "- Size: #{(smallest_mhtml[:size] / 1024.0).round(2)} KB"
    f.puts
  end

  # Pick a medium-sized file
  median_idx = results.count / 2
  median_file = results.sort_by { |r| r[:size] }[median_idx]
  f.puts '### Medium-Sized File (Representative sample)'
  f.puts "- Path: `#{median_file[:path]}`"
  f.puts "- Size: #{(median_file[:size] / 1024.0).round(2)} KB"
  f.puts "- Format: #{median_file[:format]}"
  f.puts

  # International standard samples
  intl_std = results.select { |r| r[:path].include?('international-standard') }
  if intl_std.any?
    f.puts '### International Standard Samples (Core use case)'
    intl_std.first(3).each do |result|
      f.puts "- `#{result[:path]}` (#{(result[:size] / 1024.0).round(2)} KB, #{result[:format]})"
    end
    f.puts
  end

  f.puts '## Next Steps'
  f.puts
  f.puts '1. Test reading capabilities with smallest MHTML file'
  f.puts '2. Progress to medium-sized files'
  f.puts '3. Test different document types (international-standard, amendment, etc.)'
  f.puts '4. Identify common features and gaps'
  f.puts '5. Prioritize feature implementation based on findings'
end

puts "Report saved to: #{output_file}"
puts "\nTop 5 files by size:"
results.sort_by { |r| -r[:size] }.first(5).each do |r|
  puts "  #{(r[:size] / 1024.0 / 1024.0).round(2)} MB - #{r[:path]}"
end
