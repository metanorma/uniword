#!/usr/bin/env ruby
# frozen_string_literal: true

# Script to merge extension files into their respective class files

require 'fileutils'

# Extensions to merge

puts 'Merging run_extensions.rb...'
run_ext = File.read('lib/uniword/extensions/run_extensions.rb')
run_file = File.read('lib/uniword/wordprocessingml/run.rb')

# Extract methods from run_extensions (skip module/class declarations)
run_methods = run_ext.lines[5..-3].join # Skip first 5 lines and last 3 lines

# Insert before the last 'end' statements
run_lines = run_file.lines
insert_pos = run_lines.rindex { |line| line.strip == 'end' }
run_lines.insert(insert_pos, "\n", *run_methods.lines)

File.write('lib/uniword/wordprocessingml/run.rb', run_lines.join)
puts '✓ Merged run_extensions into run.rb'

puts "\nExtension files have been merged!"
puts 'You can now remove lib/uniword/extensions/ directory'
puts 'And remove extension requires from lib/uniword.rb'
