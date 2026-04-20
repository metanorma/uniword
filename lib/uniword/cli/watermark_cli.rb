# frozen_string_literal: true

require "thor"
require_relative "helpers"

module Uniword
  # Watermark subcommand for Uniword CLI.
  #
  # Manages text watermarks in documents.
  class WatermarkCLI < Thor
    include CLIHelpers

    desc "add FILE TEXT", "Add a text watermark"
    long_desc <<~DESC
      Add a text watermark to a document.

      Examples:
        $ uniword watermark add document.docx "CONFIDENTIAL" -o out.docx
        $ uniword watermark add document.docx "DRAFT" --color "#FF0000" -o out.docx
    DESC
    option :output, aliases: "-o", required: true, type: :string
    option :color, desc: "Watermark color (hex)", type: :string,
                   default: "#808080"
    option "font-size", desc: "Font size in points", type: :numeric,
                        default: 72
    option :font, desc: "Font family", type: :string, default: "Segoe UI"
    def add(path, text)
      doc = load_document(path)
      manager = Watermark::Manager.new(doc)

      manager.add(text,
                  color: options[:color],
                  font_size: options["font-size"],
                  font: options[:font])

      doc.save(options[:output])
      say "Added watermark '#{text}' to #{options[:output]}", :green
    rescue Uniword::Error => e
      handle_error(e)
    rescue StandardError => e
      handle_error(e)
    end

    desc "remove FILE", "Remove all watermarks"
    long_desc <<~DESC
      Remove all watermarks from a document.

      Examples:
        $ uniword watermark remove document.docx -o clean.docx
    DESC
    option :output, aliases: "-o", required: true, type: :string
    def remove(path)
      doc = load_document(path)
      manager = Watermark::Manager.new(doc)

      count = manager.remove
      doc.save(options[:output])

      if count.positive?
        say "Removed #{count} watermark(s) from #{options[:output]}", :green
      else
        say "No watermarks found.", :yellow
      end
    rescue Uniword::Error => e
      handle_error(e)
    rescue StandardError => e
      handle_error(e)
    end

    desc "list FILE", "List watermarks in a document"
    long_desc <<~DESC
      Display all watermarks in a document.

      Examples:
        $ uniword watermark list document.docx
    DESC
    def list(path)
      doc = load_document(path)
      manager = Watermark::Manager.new(doc)

      watermarks = manager.list
      if watermarks.empty?
        say "No watermarks found.", :yellow
        return
      end

      say "Watermarks (#{watermarks.count}):", :green
      watermarks.each_with_index do |text, i|
        say "  #{i + 1}. #{text}"
      end
    rescue Uniword::Error => e
      handle_error(e)
    rescue StandardError => e
      handle_error(e)
    end
  end
end
