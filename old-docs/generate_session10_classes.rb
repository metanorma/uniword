#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lib/uniword/schema/model_generator'

puts '=' * 80
puts 'Uniword v2.0 - Session 10: Chart Namespace Generation'
puts '=' * 80
puts

puts 'Generating Chart (c:) namespace classes...'
puts 'Target: 70 elements'
puts

begin
  gen = Uniword::Schema::ModelGenerator.new('chart')
  results = gen.generate_all

  puts "\n#{'=' * 80}"
  puts 'Generation Summary:'
  puts '=' * 80
  puts "✅ Generated #{results.size} Chart classes"

  puts "\nGenerated files:"
  results.each do |element_name, file_path|
    puts "  ✓ #{element_name} → #{File.basename(file_path)}"
  end

  puts "\n#{'=' * 80}"
  puts 'Session 10 Status:'
  puts '=' * 80
  puts '✅ Chart schema created: 70 elements'
  puts "✅ Chart classes generated: #{results.size} files"
  puts '📁 Output directory: lib/generated/chart/'
  puts '🎯 Next: Create autoload index + test classes'
  puts '=' * 80
rescue StandardError => e
  puts "\n❌ Error during generation:"
  puts "  #{e.class}: #{e.message}"
  puts "\nBacktrace:"
  puts e.backtrace.first(10).map { |line| "  #{line}" }.join("\n")
  exit 1
end
