# frozen_string_literal: true

require "thor"
require "json"
require_relative "helpers"

module Uniword
  # Diff subcommands for Uniword CLI.
  #
  # Provides commands for comparing two DOCX files at the document
  # level (text, formatting, structure) and package level (ZIP parts,
  # XML structure).
  class DiffCLI < Thor
    include CLIHelpers

    desc "compare OLD NEW", "Compare two DOCX files (document level)"
    long_desc <<~DESC
      Compare two DOCX files at the document level.

      Shows text changes, formatting changes, structural differences,
      metadata changes, and style differences using LCS paragraph alignment.

      Examples:
        $ uniword diff compare old.docx new.docx
        $ uniword diff compare old.docx new.docx --text-only
        $ uniword diff compare old.docx new.docx --json
        $ uniword diff compare old.docx new.docx --verbose
        $ uniword diff compare old.docx new.docx --part content
    DESC
    option "text-only", desc: "Compare text only, skip formatting",
                        type: :boolean, default: false
    option :json, desc: "Output as JSON", type: :boolean, default: false
    option :verbose, aliases: "-v", desc: "Show full text in changes",
                     type: :boolean, default: false
    option :part, desc: "Focus on specific part (styles/headers/content)",
                  type: :string
    def compare(old_path, new_path)
      old_doc = load_document(old_path)
      new_doc = load_document(new_path)

      differ = Uniword::Diff::DocumentDiffer.new(
        old_doc, new_doc,
        options: build_differ_options
      )
      result = differ.diff

      if options[:json]
        formatter = Uniword::Diff::Formatter.new
        puts formatter.json(result)
      else
        formatter = Uniword::Diff::Formatter.new
        puts formatter.terminal(result, verbose: options[:verbose])
      end

      exit result.empty? ? 0 : 1
    rescue Uniword::Error => e
      handle_error(e)
    rescue StandardError => e
      handle_error(e, verbose: options[:verbose])
    end

    desc "package OLD NEW", "Compare two DOCX files (package/ZIP level)"
    long_desc <<~DESC
      Compare two DOCX files at the structural/package level.

      Detects added/removed ZIP parts, XML namespace differences,
      attribute changes, and element count differences. Useful for
      understanding what Word or other applications changed during
      repair.

      Examples:
        $ uniword diff package bad.docx repaired.docx
        $ uniword diff package bad.docx repaired.docx --json
        $ uniword diff package bad.docx repaired.docx --verbose
    DESC
    option :json, desc: "Output as JSON", type: :boolean, default: false
    option :verbose, aliases: "-v", desc: "Show XML change details",
                     type: :boolean, default: false
    def package(old_path, new_path)
      validate_file_exists(old_path)
      validate_file_exists(new_path)

      differ = Uniword::Diff::PackageDiffer.new(old_path, new_path)
      result = differ.diff

      if options[:json]
        puts result.to_json
      else
        puts format_package_diff(result, verbose: options[:verbose])
      end

      exit result.empty? ? 0 : 1
    rescue StandardError => e
      handle_error(e, verbose: options[:verbose])
    end

    private

    # Build options hash for DocumentDiffer from CLI options.
    #
    # @return [Hash]
    def build_differ_options
      {
        text_only: options["text-only"],
        part: options[:part]
      }
    end

    def validate_file_exists(path)
      return if File.exist?(path)

      say(Rainbow("  File not found: #{path}").red.bright)
      exit 1
    end

    # Format a PackageDiffResult for terminal output.
    def format_package_diff(result, verbose:)
      lines = []
      lines << "Package diff: #{File.basename(result.old_path)} -> " \
               "#{File.basename(result.new_path)}\n"
      lines << "  #{result.summary}\n"

      if result.added_parts.any?
        lines << "\n  Added parts:\n"
        result.added_parts.each { |p| lines << "    + #{p}\n" }
      end

      if result.removed_parts.any?
        lines << "\n  Removed parts:\n"
        result.removed_parts.each { |p| lines << "    - #{p}\n" }
      end

      if result.modified_parts.any?
        lines << "\n  Modified parts:\n"
        result.modified_parts.each do |p|
          delta = p.size_delta
          delta_str = delta.positive? ? "+#{delta}" : delta.to_s
          lines << "    ~ #{p.name} " \
                   "(#{p.old_size} -> #{p.new_size} bytes, #{delta_str})\n"

          next unless verbose && p.changes.any?

          p.changes.each do |change|
            lines << "      [#{change.category}] #{change.description}\n"
          end
        end
      end

      lines.join
    end
  end
end
