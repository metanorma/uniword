# frozen_string_literal: true

require "thor"
require_relative "helpers"

module Uniword
  # Generate subcommand for Uniword CLI.
  #
  # Generates DOCX documents from structured text files (YAML or
  # Markdown), using styles extracted from a source DOCX template.
  class GenerateCLI < Thor
    include CLIHelpers

    desc "generate INPUT OUTPUT",
         "Generate DOCX from structured text"
    long_desc <<~DESC
      Generate a DOCX document from a structured text file (YAML or
      Markdown), applying styles from a source DOCX template.

      Supported input formats:
        - YAML (.yml/.yaml): content array with element/text keys
        - Markdown (.md): headings (#), notes (> NOTE), body text

      Examples:
        $ uniword generate content.yml output.docx --style-source iso.dotx
        $ uniword generate document.md output.docx --style-source iso.dotx
        $ uniword generate content.yml output.docx --style-source iso.dotx --style-mapping config/style_mappings/iso_publication.yml
    DESC
    option "style-source", required: true, type: :string,
                           desc: "Source DOCX for styles"
    option "style-mapping", type: :string,
                            desc: "Path to style mapping YAML"
    option :verbose, aliases: "-v", desc: "Verbose output",
                     type: :boolean, default: false
    def generate(input_path, output_path)
      validate_style_source
      validate_input(input_path)

      say("Parsing #{input_path}...", :green) if options[:verbose]

      content = Generation::StructuredTextParser.parse(input_path)

      say("  Parsed #{content.count} elements", :cyan) if options[:verbose]

      generator = Generation::DocumentGenerator.new(
        style_source: options["style-source"],
        style_mapping: options["style-mapping"],
      )

      generator.generate(content, output_path)

      say("Generated: #{output_path}", :green)
    rescue Uniword::Error => e
      handle_error(e)
    rescue StandardError => e
      handle_error(e, verbose: options[:verbose])
    end

    private

    def validate_style_source
      source = options["style-source"]
      return if source && File.exist?(source)

      say("Style source not found: #{source}", :red)
      exit 1
    end

    def validate_input(path)
      unless File.exist?(path)
        say("Input file not found: #{path}", :red)
        exit 1
      end

      ext = File.extname(path).downcase
      return if [".yml", ".yaml", ".md"].include?(ext)

      say("Unsupported input format: #{ext}. " \
          "Use .yml, .yaml, or .md", :red)
      exit 1
    end
  end
end
