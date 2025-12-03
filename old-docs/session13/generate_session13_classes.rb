#!/usr/bin/env ruby
# frozen_string_literal: true

# Generate classes for Session 13 namespaces (Glossary, Shared Types, Document Variables)

require_relative 'lib/uniword/schema/model_generator'

puts '=' * 80
puts 'SESSION 13: Final Three Namespaces Generation'
puts '=' * 80
puts

# Track statistics
total_classes = 0
total_time = 0

# Generate Glossary namespace (20 elements)
puts '1. Generating Glossary namespace (g:)...'
puts '-' * 80
start_time = Time.now
gen_glossary = Uniword::Schema::ModelGenerator.new('glossary')
results_glossary = gen_glossary.generate_all
elapsed = Time.now - start_time
total_time += elapsed
total_classes += results_glossary.size
puts "✅ Generated #{results_glossary.size} Glossary classes in #{elapsed.round(2)}s"
puts

# Generate Shared Types namespace (15 elements)
puts '2. Generating Shared Types namespace (st:)...'
puts '-' * 80
start_time = Time.now
gen_shared_types = Uniword::Schema::ModelGenerator.new('shared_types')
results_shared_types = gen_shared_types.generate_all
elapsed = Time.now - start_time
total_time += elapsed
total_classes += results_shared_types.size
puts "✅ Generated #{results_shared_types.size} Shared Types classes in #{elapsed.round(2)}s"
puts

# Generate Document Variables namespace (10 elements)
puts '3. Generating Document Variables namespace (dv:)...'
puts '-' * 80
start_time = Time.now
gen_doc_vars = Uniword::Schema::ModelGenerator.new('document_variables')
results_doc_vars = gen_doc_vars.generate_all
elapsed = Time.now - start_time
total_time += elapsed
total_classes += results_doc_vars.size
puts "✅ Generated #{results_doc_vars.size} Document Variables classes in #{elapsed.round(2)}s"
puts

# Summary
puts '=' * 80
puts 'GENERATION COMPLETE'
puts '=' * 80
puts "Total classes generated: #{total_classes}"
puts "Total time: #{total_time.round(2)}s"
puts "Average per class: #{(total_time / total_classes).round(3)}s"
puts
puts 'Next steps:'
puts '1. Run type fix script (fix_session13_types.rb)'
puts '2. Create autoload indexes'
puts '3. Test with test_session13_autoload.rb'
puts '=' * 80
