#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lib/uniword/schema/model_generator'

puts '=' * 80
puts 'Session 12: Generating Custom XML + Bibliography Classes'
puts '=' * 80
puts

# Generate Custom XML classes
puts 'Step 1: Generating Custom XML classes...'
puts '-' * 80
gen1 = Uniword::Schema::ModelGenerator.new('customxml')
results1 = gen1.generate_all

puts "\n✅ Generated #{results1.size} Custom XML classes"

# Generate Bibliography classes
puts "\n#{'=' * 80}"
puts 'Step 2: Generating Bibliography classes...'
puts '-' * 80
gen2 = Uniword::Schema::ModelGenerator.new('bibliography')
results2 = gen2.generate_all

puts "\n✅ Generated #{results2.size} Bibliography classes"

# Apply type fixes
puts "\n#{'=' * 80}"
puts 'Step 3: Applying type fixes...'
puts '-' * 80

def fix_types_in_directory(dir_path, namespace_name)
  files = Dir.glob("#{dir_path}/*.rb")
  fixed_count = 0

  files.each do |file|
    content = File.read(file)
    original = content.dup

    # Fix bare type identifiers (ModelGenerator bug)
    content.gsub!(/, integer$/, ', :integer')
    content.gsub!(/, string$/, ', :string')
    content.gsub!(/, boolean$/, ', :boolean')

    if content != original
      File.write(file, content)
      fixed_count += 1
    end
  end

  puts "   #{namespace_name}: Fixed #{fixed_count}/#{files.size} files"
  fixed_count
end

custom_xml_fixed = fix_types_in_directory('lib/generated/customxml', 'Custom XML')
bibliography_fixed = fix_types_in_directory('lib/generated/bibliography', 'Bibliography')

puts "\n✅ Type fixes applied: #{custom_xml_fixed + bibliography_fixed} files modified"

# Summary
puts "\n#{'=' * 80}"
puts 'GENERATION COMPLETE'
puts '=' * 80
puts "Custom XML:    #{results1.size} classes generated"
puts "Bibliography:  #{results2.size} classes generated"
puts "Total:         #{results1.size + results2.size} classes"
puts "Type fixes:    #{custom_xml_fixed + bibliography_fixed} files"
puts
puts 'Next steps:'
puts '1. Create autoload indexes for both namespaces'
puts '2. Test with test_session12_autoload.rb'
puts '3. Update progress documentation'
puts '=' * 80
