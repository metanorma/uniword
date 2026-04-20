# frozen_string_literal: true

require "thor"
require "json"
require_relative "helpers"

module Uniword
  # TOC subcommands for Uniword CLI.
  #
  # Provides commands for generating, inserting, and updating
  # Table of Contents in DOCX documents:
  # - generate: list heading entries from a document
  # - insert: insert a TOC field into a document
  # - update: refresh an existing TOC field
  class TocCLI < Thor
    include CLIHelpers

    desc "generate FILE", "Generate TOC entries from headings"
    long_desc <<~DESC
      Scan a document for heading paragraphs (Heading1-Heading6) and
      display the resulting Table of Contents entries.

      Examples:
        $ uniword toc generate document.docx
        $ uniword toc generate document.docx --json
        $ uniword toc generate document.docx --max_level 2
        $ uniword toc generate document.docx --verbose
    DESC
    option :json, desc: "Output as JSON", type: :boolean, default: false
    option :verbose, aliases: "-v", desc: "Show style names and paragraph indices",
                     type: :boolean, default: false
    option :max_level, desc: "Maximum heading level (1-6)", type: :numeric,
                       default: 6
    def generate(path)
      doc = load_document(path)
      generator = Uniword::Toc::TocGenerator.new(doc)
      entries = generator.generate(max_level: options[:max_level])

      if entries.empty?
        say "No headings found in document.", :yellow
        return
      end

      if options[:json]
        puts JSON.pretty_generate(entries.map(&:to_h))
      else
        display_entries(entries)
      end
    rescue Uniword::Error => e
      handle_error(e)
    rescue StandardError => e
      handle_error(e, verbose: options[:verbose])
    end

    desc "insert FILE", "Insert TOC into document"
    long_desc <<~DESC
      Insert a Table of Contents into a document as a Structured Document
      Tag (SDT) at the specified position. The TOC field code will be
      updated when the document is opened in Microsoft Word.

      Examples:
        $ uniword toc insert document.docx -o output.docx
        $ uniword toc insert document.docx -o output.docx --position 2
        $ uniword toc insert document.docx -o output.docx --max_level 3
    DESC
    option :output, aliases: "-o", desc: "Output file path", required: true,
                    type: :string
    option :position, desc: "Insert position (0 = beginning)",
                      type: :numeric, default: 0
    option :max_level, desc: "Maximum heading level (1-6)", type: :numeric,
                       default: 3
    option :verbose, aliases: "-v", desc: "Show verbose output",
                     type: :boolean, default: false
    def insert(path)
      doc = load_document(path)
      generator = Uniword::Toc::TocGenerator.new(doc)
      entries = generator.generate(max_level: options[:max_level])

      if entries.empty?
        say "No headings found. Nothing to insert.", :yellow
        return
      end

      generator.insert(entries,
                       position: options[:position],
                       max_level: options[:max_level])

      doc.save(options[:output])

      say "TOC inserted with #{entries.count} entries at " \
          "position #{options[:position]}.", :green
      say "Saved to: #{options[:output]}", :green
    rescue Uniword::Error => e
      handle_error(e)
    rescue StandardError => e
      handle_error(e, verbose: options[:verbose])
    end

    desc "update FILE", "Update existing TOC in document"
    long_desc <<~DESC
      Re-scan headings and rebuild the first TOC field found in the
      document. The TOC will be updated when the document is next
      opened in Microsoft Word.

      Examples:
        $ uniword toc update document.docx -o output.docx
        $ uniword toc update document.docx -o output.docx --max_level 4
    DESC
    option :output, aliases: "-o", desc: "Output file path", required: true,
                    type: :string
    option :max_level, desc: "Maximum heading level (1-6)", type: :numeric,
                       default: 6
    option :verbose, aliases: "-v", desc: "Show verbose output",
                     type: :boolean, default: false
    def update(path)
      doc = load_document(path)
      generator = Uniword::Toc::TocGenerator.new(doc)
      entries = generator.update(max_level: options[:max_level])

      if entries.empty?
        say "No existing TOC found or no headings in document.", :yellow
        return
      end

      doc.save(options[:output])

      say "TOC updated with #{entries.count} entries.", :green
      say "Saved to: #{options[:output]}", :green
    rescue Uniword::Error => e
      handle_error(e)
    rescue StandardError => e
      handle_error(e, verbose: options[:verbose])
    end

    private

    # Display TOC entries in terminal format.
    #
    # @param entries [Array<Uniword::Toc::TocEntry>] Entries to display
    def display_entries(entries)
      say "Table of Contents (#{entries.count} entries):", :green

      entries.each do |entry|
        if options[:verbose]
          say "  Level #{entry.level}: #{entry.text}"
          say "    Style: #{entry.style_name || "(unknown)"}"
          say "    Paragraph index: #{entry.paragraph_index}"
        else
          puts entry.to_s
        end
      end
    end
  end
end
