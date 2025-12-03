#!/usr/bin/env ruby
# frozen_string_literal: true

# Test script for StyleSet infrastructure implementation

require 'bundler/setup'
require 'uniword'

puts '=' * 60
puts 'Testing StyleSet Infrastructure Implementation'
puts '=' * 60
puts

# Test file path
styleset_path = 'references/word-package/style-sets/Distinctive.dotx'

unless File.exist?(styleset_path)
  puts "ERROR: StyleSet file not found: #{styleset_path}"
  puts 'Please ensure the Distinctive.dotx file exists at the specified path.'
  exit 1
end

begin
  puts "Loading StyleSet from: #{styleset_path}"
  puts

  # Load the StyleSet
  styleset = Uniword::StyleSet.from_dotx(styleset_path)

  puts '✓ StyleSet loaded successfully!'
  puts
  puts 'StyleSet Details:'
  puts '-' * 60
  puts "  Name:         #{styleset.name}"
  puts "  Source File:  #{styleset.source_file}"
  puts "  Total Styles: #{styleset.styles.count}"
  puts

  # Break down by type
  puts 'Styles by Type:'
  puts '-' * 60
  puts "  Paragraph styles: #{styleset.paragraph_styles.count}"
  puts "  Character styles: #{styleset.character_styles.count}"
  puts "  Table styles:     #{styleset.table_styles.count}"
  puts

  # List first 10 paragraph styles
  if styleset.paragraph_styles.any?
    puts 'Sample Paragraph Styles (first 10):'
    puts '-' * 60
    styleset.paragraph_styles.first(10).each do |style|
      puts "  - #{style.id} (#{style.name})"
    end
    puts
  end

  # List first 5 character styles
  if styleset.character_styles.any?
    puts 'Sample Character Styles (first 5):'
    puts '-' * 60
    styleset.character_styles.first(5).each do |style|
      puts "  - #{style.id} (#{style.name})"
    end
    puts
  end

  puts '=' * 60
  puts '✓ All tests passed!'
  puts '=' * 60
rescue StandardError => e
  puts
  puts "ERROR: #{e.class}: #{e.message}"
  puts
  puts 'Backtrace:'
  puts(e.backtrace.first(10).map { |line| "  #{line}" })
  puts
  exit 1
end
