#!/usr/bin/env ruby
# frozen_string_literal: true

# scripts/process_themes.rb
# DEVELOPER-ONLY: Run once to generate copyright-free variants from MS themes
#
# Usage:
#   bundle exec ruby scripts/process_themes.rb
#   bundle exec ruby scripts/process_themes.rb --dry-run
#   bundle exec ruby scripts/process_themes.rb --source data-private/themes --output data/themes

require_relative '../lib/uniword'

module Uniword
  module Scripts
    # Developer script for processing MS Office themes into copyright-free variants
    #
    # This script is for DEVELOPERS ONLY. It takes MS Office themes from data-private/
    # and generates copyright-free variants in data/ for bundling with the gem.
    class ProcessThemes
      def initialize(source_dir:, output_dir:, dry_run: false)
        @source_dir = source_dir
        @output_dir = output_dir
        @dry_run = dry_run
        @processor = Resource::ThemeProcessor.new
        @stats = { processed: 0, skipped: 0, errors: [] }
      end

      def run
        puts "Processing themes from #{@source_dir} to #{@output_dir}"
        puts "DRY RUN - no files will be written" if @dry_run
        puts

        unless Dir.exist?(@source_dir)
          puts "Source directory not found: #{@source_dir}"
          puts "Please copy MS Office themes to data-private/themes/ first"
          return
        end

        theme_files = Dir.glob(File.join(@source_dir, '*.yml'))
        if theme_files.empty?
          puts "No theme files found in #{@source_dir}"
          return
        end

        FileUtils.mkdir_p(@output_dir) unless @dry_run

        theme_files.each do |theme_file|
          process_theme_file(theme_file)
        end

        print_summary
      end

      private

      def process_theme_file(theme_file)
        name = File.basename(theme_file, '.yml')
        puts "Processing: #{name}"

        begin
          # Load original theme
          original = Drawingml::Theme.from_yaml(File.read(theme_file))

          # Process into copyright-free variant
          processed = @processor.process(original)

          # Generate output filename
          output_file = File.join(@output_dir, "#{name}.yml")

          if @dry_run
            puts "  Would write: #{output_file}"
            @stats[:processed] += 1
          else
            File.write(output_file, processed.to_yaml)
            puts "  Written: #{output_file}"
            @stats[:processed] += 1
          end
        rescue StandardError => e
          puts "  ERROR: #{e.message}"
          puts "  #{e.backtrace.first(3).join("\n  ")}"
          @stats[:errors] << { name: name, error: e.message }
        end
      end

      def print_summary
        puts
        puts "=" * 60
        puts "Summary"
        puts "=" * 60
        puts "Processed: #{@stats[:processed]}"
        puts "Skipped:   #{@stats[:skipped]}"
        puts "Errors:    #{@stats[:errors].size}"

        if @stats[:errors].any?
          puts
          puts "Failed themes:"
          @stats[:errors].each do |err|
            puts "  - #{err[:name]}: #{err[:error]}"
          end
        end

        if @dry_run
          puts
          puts "This was a dry run. Run without --dry-run to write files."
        end
      end
    end
  end
end

# Parse command line arguments
source_dir = 'data-private/themes'
output_dir = 'data/themes'
dry_run = false

ARGV.each do |arg|
  case arg
  when '--dry-run'
    dry_run = true
  when /^--source=(.+)$/
    source_dir = Regexp.last_match(1)
  when /^--output=(.+)$/
    output_dir = Regexp.last_match(1)
  end
end

# Run the script
Uniword::Scripts::ProcessThemes.new(
  source_dir: source_dir,
  output_dir: output_dir,
  dry_run: dry_run
).run
