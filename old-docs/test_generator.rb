#!/usr/bin/env ruby
# frozen_string_literal: true

# Test schema generator infrastructure

require_relative 'lib/uniword/schema/schema_loader'
require_relative 'lib/uniword/schema/model_generator'

puts '=' * 80
puts 'Schema Generation Test'
puts '=' * 80
puts

# Test 1: Schema Loader
puts '1. Testing SchemaLoader...'
loader = Uniword::Schema::SchemaLoader.instance
begin
  loader.load_schema('wordprocessingml')
  puts '   ✓ Loaded wordprocessingml schema'

  namespace = loader.namespace('wordprocessingml')
  puts "   ✓ Namespace: #{namespace['prefix']} => #{namespace['uri']}"

  elements = loader.element_names('wordprocessingml')
  puts "   ✓ Found #{elements.size} element definitions"
  puts "     Elements: #{elements.join(', ')}"
  puts
rescue StandardError => e
  puts "   ✗ Error: #{e.message}"
  exit 1
end

# Test 2: Model Generator
puts '2. Testing ModelGenerator...'
generator = Uniword::Schema::ModelGenerator.new('wordprocessingml')
begin
  # Generate just the paragraph element as a test
  puts '   Generating Paragraph class...'
  file_path = generator.generate_element_class('p')
  puts "   ✓ Generated: #{file_path}"

  # Read and display the generated code
  code = File.read(file_path)
  puts
  puts '   Generated Code Preview:'
  puts "   #{'-' * 76}"
  code.lines.first(30).each { |line| puts "   #{line}" }
  puts "   #{'-' * 76}"
  puts

  # Verify Pattern 0: Attributes before xml block
  if code.include?('attribute :') && code.index('attribute :') < code.index('xml do')
    puts '   ✓ Pattern 0 verified: Attributes declared BEFORE xml block'
  else
    puts '   ✗ Pattern 0 violation: Check attribute order!'
    exit 1
  end

  # Loading would fail because dependencies aren't generated yet
  puts '   NOTE: Skipping load test - dependencies not yet generated'
  puts
rescue StandardError => e
  puts "   ✗ Error: #{e.message}"
  puts e.backtrace.first(5)
  exit 1
end

# Test 3: Generate All Classes
puts '3. Generating all classes...'
begin
  results = generator.generate_all
  puts "   ✓ Generated #{results.size} classes:"
  results.each do |element, path|
    relative_path = path.sub("#{Dir.pwd}/", '')
    puts "     - #{element.ljust(20)} => #{relative_path}"
  end
  puts
rescue StandardError => e
  puts "   ✗ Error: #{e.message}"
  puts e.backtrace.first(5)
  exit 1
end

puts '=' * 80
puts '✓ ALL TESTS PASSED'
puts '=' * 80
puts
puts 'Next Steps:'
puts '1. Complete WordProcessingML schema (add remaining 190+ elements)'
puts '2. Create schemas for other namespaces (math, drawing, vml, etc.)'
puts '3. Generate all 600+ classes'
puts '4. Build schema-driven serializer/deserializer'
