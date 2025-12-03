#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lib/uniword/schema/model_generator'

puts '=' * 80
puts 'Session 11: Generating PresentationML Classes'
puts '=' * 80
puts

generator = Uniword::Schema::ModelGenerator.new('presentationml')
results = generator.generate_all

puts "\n#{'=' * 80}"
puts 'Generation Complete!'
puts '=' * 80
puts "Total classes generated: #{results.size}"
puts 'Location: lib/generated/presentationml/'
puts

# Show first 10 classes as sample
puts 'Sample classes:'
results.first(10).each do |result|
  puts "  ✓ #{result[:class_name]}"
end

puts "\nRun: ruby test_session11_autoload.rb to test autoload pattern"
