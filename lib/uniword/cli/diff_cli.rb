# frozen_string_literal: true

require "thor"
require "json"
require_relative "helpers"

module Uniword
  # Diff subcommands for Uniword CLI.
  #
  # Provides commands for comparing two DOCX files and displaying
  # differences in text, formatting, structure, metadata, and styles.
  class DiffCLI < Thor
    include CLIHelpers

    desc "compare OLD NEW", "Compare two DOCX files"
    long_desc <<~DESC
      Compare two DOCX files and display differences.

      Shows text changes, formatting changes, structural differences,
      metadata changes, and style differences.

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
  end
end
