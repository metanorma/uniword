#!/usr/bin/env ruby
# Script to merge extension files into their respective class files

require 'fileutils'

# Extensions to merge
extensions = {
  'lib/uniword/extensions/run_extensions.rb' => 'lib/uniword/wordprocessingml/run.rb',
  'lib/uniword/extensions/properties_extensions.rb' => [
    'lib/uniword/wordprocessingml/paragraph_properties.rb',
    'lib/uniword/wordprocessingml/run_properties.rb',
    'lib/uniword/wordprocessingml/table_properties.rb'
  ]
}

puts "Merging run_extensions.rb..."
run_ext = File.read('lib/uniword/extensions/run_extensions.rb')
run_file = File.read('lib/uniword/wordprocessingml/run.rb')

# Extract methods from run_extensions (skip module/class declarations)
run_methods = run_ext.lines[5..-3].join # Skip first 5 lines and last 3 lines

# Insert before the last 'end' statements
run_lines = run_file.lines
insert_pos = run_lines.rindex { |line| line.strip == 'end' }
run_lines.insert(insert_pos, "\n", *run_methods.lines)

File.write('lib/uniword/wordprocessingml/run.rb', run_lines.join)
puts "✓ Merged run_extensions into run.rb"

puts "\nExtension files have been merged!"
puts "You can now remove lib/uniword/extensions/ directory"
puts "And remove extension requires from lib/uniword.rb"