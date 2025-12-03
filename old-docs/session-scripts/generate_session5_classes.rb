#!/usr/bin/env ruby
# frozen_string_literal: true

# Session 5: Generate DrawingML (expanded), Picture, and Relationships classes

require_relative 'lib/uniword/schema/model_generator'

puts '=' * 80
puts 'Session 5: Class Generation'
puts '=' * 80
puts

# Generate DrawingML classes (expanded to 92 elements)
puts '1. Generating DrawingML classes (expanded)...'
drawingml_gen = Uniword::Schema::ModelGenerator.new('drawingml')
drawingml_results = drawingml_gen.generate_all
puts "   ✅ Generated #{drawingml_results.size} DrawingML classes"
puts

# Generate Picture classes (10 elements)
puts '2. Generating Picture classes...'
picture_gen = Uniword::Schema::ModelGenerator.new('picture')
picture_results = picture_gen.generate_all
puts "   ✅ Generated #{picture_results.size} Picture classes"
puts

# Generate Relationships classes (5 elements)
puts '3. Generating Relationships classes...'
relationships_gen = Uniword::Schema::ModelGenerator.new('relationships')
relationships_results = relationships_gen.generate_all
puts "   ✅ Generated #{relationships_results.size} Relationships classes"
puts

# Summary
puts '=' * 80
puts 'Generation Complete!'
puts '=' * 80
puts "DrawingML:     #{drawingml_results.size} classes"
puts "Picture:       #{picture_results.size} classes"
puts "Relationships: #{relationships_results.size} classes"
puts '-' * 80
puts "Total:         #{drawingml_results.size + picture_results.size + relationships_results.size} classes"
puts '=' * 80
