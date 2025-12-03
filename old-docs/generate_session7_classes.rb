#!/usr/bin/env ruby
# frozen_string_literal: true

# Generate classes for Session 7: Office, VML Office, and Document Properties

require_relative 'lib/uniword/schema/model_generator'

puts '=' * 80
puts 'SESSION 7: Generating Office, VML Office, and Document Properties Classes'
puts '=' * 80
puts

# Generate Office namespace
puts '1. Generating Office namespace (40 elements)...'
puts '-' * 80
gen_office = Uniword::Schema::ModelGenerator.new('office')
results_office = gen_office.generate_all
puts "✅ Generated #{results_office.size} Office classes"
puts

# Generate VML Office namespace
puts '2. Generating VML Office namespace (25 elements)...'
puts '-' * 80
gen_vml_office = Uniword::Schema::ModelGenerator.new('vml_office')
results_vml_office = gen_vml_office.generate_all
puts "✅ Generated #{results_vml_office.size} VML Office classes"
puts

# Generate Document Properties namespace
puts '3. Generating Document Properties namespace (20 elements)...'
puts '-' * 80
gen_doc_props = Uniword::Schema::ModelGenerator.new('document_properties')
results_doc_props = gen_doc_props.generate_all
puts "✅ Generated #{results_doc_props.size} Document Properties classes"
puts

# Summary
puts '=' * 80
puts 'GENERATION SUMMARY'
puts '=' * 80
puts "Office:               #{results_office.size} classes"
puts "VML Office:           #{results_vml_office.size} classes"
puts "Document Properties:  #{results_doc_props.size} classes"
puts "Total New Classes:    #{results_office.size + results_vml_office.size + results_doc_props.size}"
puts
puts '✅ All Session 7 classes generated successfully!'
puts '=' * 80
