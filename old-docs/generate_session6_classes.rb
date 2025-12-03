#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lib/uniword/schema/model_generator'

puts '=' * 80
puts 'SESSION 6: Generating Classes for WP Drawing, Content Types, and VML'
puts '=' * 80
puts

# Track total results
total_generated = 0
all_results = {}

# Generate WP Drawing classes
puts '1. Generating WP Drawing namespace classes...'
puts '-' * 80
begin
  gen_wp = Uniword::Schema::ModelGenerator.new('wp_drawing')
  results_wp = gen_wp.generate_all
  all_results[:wp_drawing] = results_wp
  total_generated += results_wp.size
  puts "✅ Successfully generated #{results_wp.size} WP Drawing classes"
  results_wp.first(3).each do |class_name, file_path|
    puts "   - #{class_name} -> #{file_path}"
  end
  puts "   ... and #{results_wp.size - 3} more" if results_wp.size > 3
rescue StandardError => e
  puts "❌ Error generating WP Drawing: #{e.message}"
  puts e.backtrace.first(5).join("\n")
end
puts

# Generate Content Types classes
puts '2. Generating Content Types namespace classes...'
puts '-' * 80
begin
  gen_ct = Uniword::Schema::ModelGenerator.new('content_types')
  results_ct = gen_ct.generate_all
  all_results[:content_types] = results_ct
  total_generated += results_ct.size
  puts "✅ Successfully generated #{results_ct.size} Content Types classes"
  results_ct.each do |class_name, file_path|
    puts "   - #{class_name} -> #{file_path}"
  end
rescue StandardError => e
  puts "❌ Error generating Content Types: #{e.message}"
  puts e.backtrace.first(5).join("\n")
end
puts

# Generate VML classes
puts '3. Generating VML namespace classes...'
puts '-' * 80
begin
  gen_vml = Uniword::Schema::ModelGenerator.new('vml')
  results_vml = gen_vml.generate_all
  all_results[:vml] = results_vml
  total_generated += results_vml.size
  puts "✅ Successfully generated #{results_vml.size} VML classes"
  results_vml.first(5).each do |class_name, file_path|
    puts "   - #{class_name} -> #{file_path}"
  end
  puts "   ... and #{results_vml.size - 5} more" if results_vml.size > 5
rescue StandardError => e
  puts "❌ Error generating VML: #{e.message}"
  puts e.backtrace.first(5).join("\n")
end
puts

# Summary
puts '=' * 80
puts 'GENERATION SUMMARY'
puts '=' * 80
puts "Total classes generated: #{total_generated}"
puts
puts 'Breakdown by namespace:'
all_results.each do |namespace, results|
  puts "  - #{namespace}: #{results.size} classes"
end
puts
puts 'Next steps:'
puts '  1. Create autoload indices for each namespace'
puts '  2. Test autoload functionality'
puts '  3. Update documentation'
puts '=' * 80
