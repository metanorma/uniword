# frozen_string_literal: true

require "thor"

module Uniword
  # Fonts subcommands for Uniword CLI.
  #
  # Rewrites font families inside document content — the CLI equivalent
  # of Word's Home → Replace → Replace Fonts, across styles, defaults,
  # body, headers/footers, notes, comments, and numbering in one pass.
  class FontsCLI < Thor
    include CLIHelpers

    desc "replace INPUT OUTPUT", "Replace a font family throughout a document"
    long_desc <<~DESC
      Replace one font family with another across styles and defaults,
      body content, headers/footers, notes, comments, and numbering —
      Word's Replace Fonts dialog as a one-shot CLI command. Theme font
      references are untouched; use 'uniword theme fonts' for those.

      Examples:
        $ uniword fonts replace input.docx output.docx --from Calibri --to Carlito
    DESC
    option :from, type: :string, required: true,
                  desc: "Font family to replace (exact match)"
    option :to, type: :string, required: true,
                desc: "Replacement font family"
    option :verbose, aliases: "-v", desc: "Verbose output", type: :boolean,
                     default: false
    def replace(input_path, output_path)
      say "Loading document #{input_path}...", :green if options[:verbose]

      count = replace_in_file(input_path, output_path)
      say "Replaced #{count} font reference(s) " \
          "('#{options[:from]}' → '#{options[:to]}') in #{output_path}",
          :green
    rescue Uniword::Error => e
      handle_error(e)
    rescue StandardError => e
      handle_error(e, verbose: options[:verbose])
    end

    private

    def replace_in_file(input_path, output_path)
      doc = load_document(input_path)
      count = doc.replace_font(from: options[:from], to: options[:to])
      doc.save(output_path)
      count
    end
  end
end
