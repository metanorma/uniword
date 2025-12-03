#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lib/uniword/schema/model_generator'

puts '=' * 80
puts 'Session 9: SpreadsheetML Namespace Generation'
puts '=' * 80
puts

# Generate SpreadsheetML classes
puts 'Generating SpreadsheetML classes...'
generator = Uniword::Schema::ModelGenerator.new('spreadsheetml')
results = generator.generate_all

puts "\n✅ Generation complete!"
puts "   - Total classes generated: #{results.size}"
puts '   - Namespace: xls:'
puts '   - Output directory: lib/generated/spreadsheetml/'

puts "\nSample classes generated:"
results.first(10).each do |result|
  puts "   - #{result}"
end

puts "\n#{'=' * 80}"
puts 'Next steps:'
puts '1. Run: ruby generate_session9_classes.rb'
puts '2. Create autoload index'
puts '3. Test with: ruby test_session9_autoload.rb'
puts '=' * 80
