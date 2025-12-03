#!/usr/bin/env ruby
# frozen_string_literal: true

# Test theme media extraction and inclusion in generated documents

require 'lutaml/model'
require_relative 'lib/uniword/element'
require_relative 'lib/uniword/properties/paragraph_properties'
require_relative 'lib/uniword/properties/run_properties'
require_relative 'lib/uniword/theme'
require_relative 'lib/uniword/color_scheme'
require_relative 'lib/uniword/font_scheme'
require_relative 'lib/uniword/theme/theme_variant'
require_relative 'lib/uniword/theme/media_file'
require_relative 'lib/uniword/infrastructure/zip_extractor'
require_relative 'lib/uniword/theme/theme_package_reader'
require_relative 'lib/uniword/theme/theme_xml_parser'
require_relative 'lib/uniword/theme/theme_loader'

puts '=' * 80
puts 'Theme Media Extraction Test'
puts '=' * 80
puts

# Test with Integral theme (.thmx file)
thmx_file = 'references/word-package/office-themes/Integral.thmx'

unless File.exist?(thmx_file)
  puts "❌ Error: #{thmx_file} not found"
  exit 1
end

begin
  # Step 1: Extract theme package
  puts 'Step 1: Extracting theme package...'
  reader = Uniword::Themes::ThemePackageReader.new
  extracted = reader.extract(thmx_file)

  puts '  ✓ Theme package extracted'
  puts "    Base theme: #{extracted[:base] ? 'present' : 'missing'}"
  puts "    Variants: #{extracted[:variants].count}"
  puts "    Media files: #{extracted[:media].count}"
  puts

  if extracted[:media].any?
    puts '  Media files extracted:'
    extracted[:media].each do |filename, media_file|
      puts "    - #{filename}: #{media_file.size} bytes (#{media_file.content_type})"
    end
    puts
  end

  # Step 2: Load theme with media
  puts 'Step 2: Loading theme...'
  loader = Uniword::Themes::ThemeLoader.new
  theme = loader.load(thmx_file)

  puts '  ✓ Theme loaded'
  puts "    Name: #{theme.name}"
  puts "    Media files: #{theme.media_files.count}"
  puts

  if theme.media_files.any?
    puts '  Theme media files:'
    theme.media_files.each do |filename, media_file|
      puts "    - #{filename}: #{media_file.size} bytes"
    end
    puts
  end

  puts '=' * 80
  puts '✓ COMPLETE - Theme media extraction working!'
  puts '=' * 80
rescue StandardError => e
  puts "❌ Error: #{e.message}"
  puts e.backtrace.first(10)
  exit 1
end
