# frozen_string_literal: true

require "thor"

module Uniword
  # Styles subcommands for Uniword CLI.
  #
  # Inspect the styles inside a document — the CLI equivalent of Word's
  # Styles pane.
  class StylesCLI < Thor
    include CLIHelpers

    desc "list FILE", "List styles in a document"
    long_desc <<~DESC
      List all styles defined in a document with their type, base
      style, and key formatting — the CLI equivalent of Word's Styles
      pane.

      Examples:
        $ uniword styles list report.docx
        $ uniword styles list report.docx --type paragraph
        $ uniword styles list report.docx --verbose
    DESC
    option :type, type: :string,
                  desc: "Filter by type: paragraph, character, table, numbering"
    option :verbose, aliases: "-v", desc: "Show formatting details",
                     type: :boolean, default: false
    def list(path)
      styles = gather_styles(path)
      if styles.empty?
        say "No styles found.", :yellow
        return
      end

      say "Styles in #{File.basename(path)} (#{styles.size}):", :green
      styles.each { |style| print_style(style) }
    rescue Uniword::Error => e
      handle_error(e)
    rescue StandardError => e
      handle_error(e, verbose: options[:verbose])
    end

    private

    def gather_styles(path)
      doc = load_document(path)
      filter_type(doc.styles_configuration.styles || [])
    end

    def filter_type(styles)
      return styles unless options[:type]

      styles.select { |s| s.type == options[:type] }
    end

    def print_style(style)
      base = style.basedOn&.val || "-"
      line = format("  %-24<id>s %-10<type>s base: %<base>s",
                    id: style.styleId, type: style.type, base: base)
      line += "  [#{style_details(style)}]" if options[:verbose]
      say line
    end

    def style_details(style)
      (name_detail(style) + font_details(style) + format_details(style))
        .join(", ")
    end

    def name_detail(style)
      style.name&.val ? ["name=#{style.name.val}"] : []
    end

    def font_details(style)
      rpr = style.rPr
      return [] unless rpr

      [font_name(rpr), font_size(rpr)].compact
    end

    def font_name(rpr)
      rpr.fonts&.ascii
    end

    def font_size(rpr)
      size = rpr.size&.value
      "#{size.to_i / 2.0}pt" if size
    end

    def format_details(style)
      rpr = style.rPr
      return [] unless rpr

      flags = []
      flags << "bold" if rpr.bold&.val
      flags << "italic" if rpr.italic&.val
      flags
    end
  end
end
