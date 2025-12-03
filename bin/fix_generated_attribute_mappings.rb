#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'

# Script to fix incorrect attribute mappings in generated classes
# Changes: map_attribute 'true', to: :attr_name
# To:      map_attribute 'attr-name', to: :attr_name

def convert_ruby_symbol_to_xml_attribute(symbol_name)
  # Convert Ruby symbol (snake_case) to XML attribute (kebab-case)
  symbol_name.gsub('_', '-')
end

def fix_file(file_path)
  content = File.read(file_path)
  content.dup
  modified = false

  # Find all occurrences of: map_attribute 'true', to: :symbol_name
  content.gsub!(/map_attribute\s+'true',\s+to:\s+:(\w+)/) do |_match|
    symbol_name = Regexp.last_match(1)
    xml_attr_name = convert_ruby_symbol_to_xml_attribute(symbol_name)
    modified = true
    "map_attribute '#{xml_attr_name}', to: :#{symbol_name}"
  end

  if modified
    File.write(file_path, content)
    puts "✓ Fixed: #{file_path}"
    true
  else
    false
  end
end

def main
  # Find all Ruby files under lib/generated/
  pattern = File.join(__dir__, '../lib/generated/**/*.rb')
  files = Dir.glob(pattern)

  puts "Scanning #{files.length} files under lib/generated/..."
  puts

  fixed_count = 0
  files.each do |file|
    fixed_count += 1 if fix_file(file)
  end

  puts
  puts '=' * 60
  puts "Summary: Fixed #{fixed_count} file(s)"
  puts '=' * 60
end

main if __FILE__ == $PROGRAM_NAME
