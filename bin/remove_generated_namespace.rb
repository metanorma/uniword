#!/usr/bin/env ruby
# frozen_string_literal: true

# Script to remove the "module Generated" layer from all generated files

require 'fileutils'

# Directories containing generated files
dirs = %w[
  lib/uniword/wordprocessingml
  lib/uniword/drawingml
  lib/uniword/math
  lib/uniword/content_types
  lib/uniword/document_properties
  lib/uniword/document_variables
  lib/uniword/glossary
  lib/uniword/chart
  lib/uniword/picture
  lib/uniword/presentationml
  lib/uniword/spreadsheetml
  lib/uniword/relationships
  lib/uniword/shared_types
  lib/uniword/vml_office
  lib/uniword/wp_drawing
  lib/uniword/customxml
  lib/uniword/bibliography
  lib/uniword/office
  lib/uniword/wordprocessingml_2010
  lib/uniword/wordprocessingml_2013
  lib/uniword/wordprocessingml_2016
]

files_updated = 0

dirs.each do |dir|
  next unless File.directory?(dir)

  Dir.glob("#{dir}/**/*.rb").each do |file|
    content = File.read(file)
    original = content.dup

    # Remove "  module Generated" line
    content.gsub!(/^  module Generated\n/, '')

    # Remove one "  end" statement (the one matching Generated)
    # We need to be careful - only remove if we found Generated
    next unless original != content

    # Count the number of "end" statements
    # Remove the second-to-last "  end" (which closes Generated module)
    lines = content.lines
    end_indices = []
    lines.each_with_index do |line, i|
      end_indices << i if line.strip == 'end'
    end

    if end_indices.length >= 2
      # Remove the second-to-last end (closes Generated)
      lines.delete_at(end_indices[-2])
      content = lines.join
    end

    File.write(file, content)
    files_updated += 1
    puts "Updated: #{file}"
  end
end

puts "\nTotal files updated: #{files_updated}"
