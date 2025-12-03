#!/usr/bin/env ruby
# frozen_string_literal: true

# Fix type identifiers in Session 13 generated classes (ModelGenerator bug)
# Changes: integer → :integer, string → :string

puts '=' * 80
puts 'SESSION 13: Type Fix Script'
puts '=' * 80
puts

namespaces = %w[glossary shared_types document_variables]
total_files = 0
total_fixes = 0

namespaces.each do |namespace|
  puts "Processing #{namespace} namespace..."

  files = Dir.glob("lib/generated/#{namespace}/*.rb")
  namespace_fixes = 0

  files.each do |file|
    content = File.read(file)
    original_content = content.dup

    # Fix primitive types
    content.gsub!(/, integer$/, ', :integer')
    content.gsub!(/, string$/, ', :string')
    content.gsub!(/, boolean$/, ', :boolean')

    if content != original_content
      File.write(file, content)
      namespace_fixes += 1
    end
  end

  puts "  ✅ Fixed #{namespace_fixes} files in #{namespace}"
  total_files += files.size
  total_fixes += namespace_fixes
end

puts
puts '=' * 80
puts 'TYPE FIX COMPLETE'
puts '=' * 80
puts "Total files processed: #{total_files}"
puts "Total files fixed: #{total_fixes}"
puts
puts 'Next step: Create autoload indexes'
puts '=' * 80
