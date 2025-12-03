#!/usr/bin/env ruby
# frozen_string_literal: true

# Generate classes for Session 8: Word Extended Namespaces

require_relative 'lib/uniword/schema/model_generator'

puts '=' * 80
puts 'Session 8: Generating Word Extended Namespace Classes'
puts '=' * 80
puts

# Word 2010 Extended (w14:)
puts 'Generating Word 2010 Extended classes (w14:)...'
gen_2010 = Uniword::Schema::ModelGenerator.new('wordprocessingml_2010')
results_2010 = gen_2010.generate_all
puts "✅ Generated #{results_2010.size} Word 2010 classes"
puts

# Word 2013 Extended (w15:)
puts 'Generating Word 2013 Extended classes (w15:)...'
gen_2013 = Uniword::Schema::ModelGenerator.new('wordprocessingml_2013')
results_2013 = gen_2013.generate_all
puts "✅ Generated #{results_2013.size} Word 2013 classes"
puts

# Word 2016 Extended (w16:)
puts 'Generating Word 2016 Extended classes (w16:)...'
gen_2016 = Uniword::Schema::ModelGenerator.new('wordprocessingml_2016')
results_2016 = gen_2016.generate_all
puts "✅ Generated #{results_2016.size} Word 2016 classes"
puts

# Summary
total = results_2010.size + results_2013.size + results_2016.size
puts '=' * 80
puts 'Session 8 Generation Complete!'
puts '=' * 80
puts "Total classes generated: #{total}"
puts "  - Word 2010 (w14:): #{results_2010.size} classes"
puts "  - Word 2013 (w15:): #{results_2013.size} classes"
puts "  - Word 2016 (w16:): #{results_2016.size} classes"
puts
puts 'Progress Update:'
puts '  Previous: 402 elements (11 namespaces)'
puts "  Added: #{total} elements (3 namespaces)"
puts "  Current: #{402 + total} elements (14 namespaces)"
puts "  Completion: #{((402 + total) * 100.0 / 760).round(1)}%"
puts '=' * 80
