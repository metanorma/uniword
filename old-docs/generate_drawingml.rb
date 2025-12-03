#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lib/uniword/schema/model_generator'

puts 'Generating DrawingML classes...'
puts '=' * 60

generator = Uniword::Schema::ModelGenerator.new('drawingml')
results = generator.generate_all

puts 'Generation complete!'
puts "Generated #{results.size} classes:"
puts

results.each do |element_name, file_path|
  puts "  ✓ #{element_name} -> #{file_path}"
end

puts
puts '=' * 60
puts "Total: #{results.size} DrawingML classes generated"
