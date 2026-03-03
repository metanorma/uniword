#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pathname'

# Update all references from Properties::ParagraphProperties
# to Ooxml::WordProcessingML::ParagraphProperties

class ReferenceUpdater
  OLD_PATTERNS = [
    'Properties::ParagraphProperties',
    'Uniword::Properties::ParagraphProperties'
  ].freeze

  NEW_REFERENCE = 'Ooxml::WordProcessingML::ParagraphProperties'

  def initialize(base_dir)
    @base_dir = Pathname.new(base_dir)
    @updates = []
  end

  def update_all
    puts '=' * 80
    puts 'UPDATING PARAGRAPH_PROPERTIES REFERENCES'
    puts '=' * 80
    puts

    lib_dir = @base_dir / 'lib'

    lib_dir.glob('**/*.rb').each do |file|
      update_file(file)
    end

    report_results
  end

  private

  def update_file(file)
    content = file.read
    original_content = content.dup
    modified = false

    OLD_PATTERNS.each do |pattern|
      if content.include?(pattern)
        content.gsub!(pattern, NEW_REFERENCE)
        modified = true
      end
    end

    return unless modified

    file.write(content)
    rel_path = file.relative_path_from(@base_dir)
    @updates << {
      file: rel_path.to_s,
      changes: count_changes(original_content, content)
    }
    puts "✅ Updated: #{rel_path}"
  end

  def count_changes(original, updated)
    original_lines = original.lines
    updated_lines = updated.lines

    changes = 0
    [original_lines.size, updated_lines.size].max.times do |i|
      changes += 1 if original_lines[i] != updated_lines[i]
    end

    changes
  end

  def report_results
    puts
    puts '=' * 80
    puts 'UPDATE SUMMARY'
    puts '=' * 80
    puts

    if @updates.empty?
      puts 'No files needed updating.'
    else
      puts "Updated #{@updates.size} file(s):"
      @updates.each do |update|
        puts "  #{update[:file]} (#{update[:changes]} line(s) changed)"
      end
    end

    puts
    puts 'Next steps:'
    puts '  1. Run tests: bundle exec rspec'
    puts '  2. If tests pass, delete old files'
    puts '  3. Repeat for run_properties and table_properties'
  end
end

if __FILE__ == $PROGRAM_NAME
  base_dir = File.expand_path('..', __dir__)
  updater = ReferenceUpdater.new(base_dir)
  updater.update_all
end
