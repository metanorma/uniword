#!/usr/bin/env ruby
# frozen_string_literal: true

# Standalone StyleSet import script that avoids circular dependencies
# Loads only necessary components for StyleSet import

require 'lutaml/model'
require 'fileutils'
require_relative '../lib/uniword/element'
require_relative '../lib/uniword/properties/paragraph_properties'
require_relative '../lib/uniword/properties/run_properties'
require_relative '../lib/uniword/properties/table_properties'
require_relative '../lib/uniword/style'
require_relative '../lib/uniword/styleset'
require_relative '../lib/uniword/infrastructure/zip_extractor'
require_relative '../lib/uniword/stylesets/styleset_package_reader'
require_relative '../lib/uniword/stylesets/styleset_xml_parser'
require_relative '../lib/uniword/stylesets/styleset_loader'

# Configuration
SOURCE_DIR = 'references/word-package/style-sets'
OUTPUT_DIR = 'data/stylesets'

puts "=" * 80
puts "StyleSet Import Script (Standalone)"
puts "=" * 80
puts
puts "Source: #{SOURCE_DIR}"
puts "Output: #{OUTPUT_DIR}"
puts

# Ensure output directory exists
FileUtils.mkdir_p(OUTPUT_DIR)

# Import all StyleSets
count = 0
Dir.glob(File.join(SOURCE_DIR, '*.dotx')).each do |dotx_file|
  styleset_name = File.basename(dotx_file, '.dotx')
    .downcase
    .gsub(/[^a-z0-9]+/, '_')
    .gsub(/^_|_$/, '')

  output_file = File.join(OUTPUT_DIR, "#{styleset_name}.yml")

  puts "Importing #{File.basename(dotx_file)} -> #{File.basename(output_file)}"

  begin
    # Load StyleSet
    loader = Uniword::StyleSets::StyleSetLoader.new
    styleset = loader.load(dotx_file)

    # Serialize to YAML
    File.write(output_file, styleset.to_yaml)

    puts "  ✓ Imported: #{styleset.styles.count} styles"
    puts "    - With paragraph properties: #{styleset.styles.count { |s| s.paragraph_properties }}"
    puts "    - With run properties: #{styleset.styles.count { |s| s.run_properties }}"
    puts "    - With table properties: #{styleset.styles.count { |s| s.table_properties }}"

    count += 1
  rescue StandardError => e
    puts "  ❌ Error: #{e.message}"
  end

  puts
end

puts "=" * 80
puts "Import Complete!"
puts "=" * 80
puts "Imported #{count} StyleSets to #{OUTPUT_DIR}/"
puts

# List imported StyleSets
stylesets = Dir.glob(File.join(OUTPUT_DIR, '*.yml')).map { |f| File.basename(f, '.yml') }.sort
puts "Available StyleSets:"
stylesets.each { |name| puts "  - #{name}" }