#!/usr/bin/env ruby
# frozen_string_literal: true

# Comprehensive verification that generated demo_formal_integral.docx
# is semantically equivalent to the reference demo_formal_integral_proper.docx

require 'canon/comparison'

puts '=' * 80
puts 'Demo Formal Integral: Comprehensive Verification'
puts '=' * 80
puts

# Unzip both documents
puts 'Step 1: Extracting packages...'
system('cd examples && unzip -qo demo_formal_integral.docx -d demo_current')
system('cd examples && unzip -qo demo_formal_integral_proper.docx -d demo_reference')
puts '  ✓ Packages extracted'
puts

# Compare all XML files
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

puts 'Step 2: Comparing XML files with Canon...'
puts

results = {}
xml_files.each do |xml_file|
  current_path = "examples/demo_current/#{xml_file}"
  reference_path = "examples/demo_reference/#{xml_file}"

  # Check if both files exist
  current_exists = File.exist?(current_path)
  reference_exists = File.exist?(reference_path)

  unless current_exists && reference_exists
    results[xml_file] = {
      status: :missing,
      current: current_exists,
      reference: reference_exists
    }
    next
  end

  # Read both files
  current_xml = File.read(current_path)
  reference_xml = File.read(reference_path)

  # Use Canon for semantic comparison
  # Match profile: spec_friendly (ignores formatting differences)
  equivalent = Canon::Comparison.equivalent?(
    current_xml,
    reference_xml,
    match_profile: :spec_friendly
  )

  results[xml_file] = {
    status: equivalent ? :equivalent : :different,
    current_size: current_xml.bytesize,
    reference_size: reference_xml.bytesize
  }
end

puts
puts '=' * 80
puts 'Verification Results'
puts '=' * 80
puts

# Summary by status
equivalent_count = results.values.count { |r| r[:status] == :equivalent }
different_count = results.values.count { |r| r[:status] == :different }
missing_count = results.values.count { |r| r[:status] == :missing }

puts 'Summary:'
puts "  ✓ Equivalent: #{equivalent_count}/#{xml_files.count}"
puts "  ⚠ Different: #{different_count}/#{xml_files.count}"
puts "  ❌ Missing: #{missing_count}/#{xml_files.count}"
puts

# Detailed results
results.each do |file, result|
  case result[:status]
  when :equivalent
    puts "  ✓ #{file}"
    puts "    Semantically equivalent (Current: #{result[:current_size]} bytes, Reference: #{result[:reference_size]} bytes)"
  when :different
    puts "  ⚠ #{file}"
    puts "    Semantically different (Current: #{result[:current_size]} bytes, Reference: #{result[:reference_size]} bytes)"
  when :missing
    puts "  ❌ #{file}"
    puts "    Current: #{result[:current] ? 'exists' : 'MISSING'}, Reference: #{result[:reference] ? 'exists' : 'MISSING'}"
  end
end

puts
puts '=' * 80

if different_count.zero? && missing_count.zero?
  puts '✓ COMPLETE VERIFICATION - All XML files semantically equivalent!'
  puts '=' * 80
  exit 0
else
  puts "⚠ VERIFICATION INCOMPLETE - #{different_count + missing_count} files need attention"
  puts '=' * 80
  exit 1
end
