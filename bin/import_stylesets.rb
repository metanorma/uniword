#!/usr/bin/env ruby
# frozen_string_literal: true

# Script to import StyleSet (.dotx) files to YAML format
# Usage: ruby bin/import_stylesets.rb

require_relative '../lib/uniword'
require_relative '../lib/uniword/stylesets/styleset_importer'

# Configuration
SOURCE_DIR = 'references/word-package/style-sets'
OUTPUT_DIR = 'data/stylesets'

puts "=" * 80
puts "StyleSet Import Script"
puts "=" * 80
puts
puts "Source: #{SOURCE_DIR}"
puts "Output: #{OUTPUT_DIR}"
puts

# Create importer
importer = Uniword::StyleSets::StyleSetImporter.new

# Import all StyleSets
begin
  count = importer.import_all(SOURCE_DIR, OUTPUT_DIR)

  puts
  puts "=" * 80
  puts "Import Complete!"
  puts "=" * 80
  puts "Imported #{count} StyleSets to #{OUTPUT_DIR}/"
  puts

  # List imported StyleSets
  stylesets = Dir.glob(File.join(OUTPUT_DIR, '*.yml')).map { |f| File.basename(f, '.yml') }.sort
  puts "Available StyleSets:"
  stylesets.each { |name| puts "  - #{name}" }

rescue StandardError => e
  puts
  puts "ERROR: #{e.message}"
  puts e.backtrace.first(5).join("\n")
  exit 1
end