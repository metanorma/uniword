#!/usr/bin/env ruby
# frozen_string_literal: true

# Script to import Office theme (.thmx) files to YAML format
# Usage: ruby bin/import_themes.rb

require_relative '../lib/uniword'
require_relative '../lib/uniword/themes/theme_importer'

# Configuration
SOURCE_DIR = 'references/word-package/office-themes'
OUTPUT_DIR = 'data/themes'

puts "=" * 80
puts "Office Theme Import Script"
puts "=" * 80
puts
puts "Source: #{SOURCE_DIR}"
puts "Output: #{OUTPUT_DIR}"
puts

# Create importer
importer = Uniword::Themes::ThemeImporter.new

# Import all themes
begin
  count = importer.import_all(SOURCE_DIR, OUTPUT_DIR)

  puts
  puts "=" * 80
  puts "Import Complete!"
  puts "=" * 80
  puts "Imported #{count} themes to #{OUTPUT_DIR}/"
  puts

  # List imported themes
  themes = Dir.glob(File.join(OUTPUT_DIR, '*.yml')).map { |f| File.basename(f, '.yml') }.sort
  puts "Available themes:"
  themes.each { |name| puts "  - #{name}" }

rescue StandardError => e
  puts
  puts "ERROR: #{e.message}"
  puts e.backtrace.first(5).join("\n")
  exit 1
end