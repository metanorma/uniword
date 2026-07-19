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

    desc "remove FILE OUTPUT", "Remove styles from a document"
    long_desc <<~DESC
      Remove styles from a document: one style with --id, or every
      style that no content references with --unused (Word's Styles-pane
      decluttering as a one-shot command). Default styles are kept.

      Examples:
        $ uniword styles remove input.docx output.docx --id ObsoleteStyle
        $ uniword styles remove input.docx output.docx --unused
        $ uniword styles remove input.docx output.docx --unused --dry-run
    DESC
    option :id, type: :string, desc: "Style id to remove"
    option :unused, type: :boolean, default: false,
                    desc: "Remove all unreferenced styles"
    option :dry_run, type: :boolean, default: false,
                     desc: "List what would be removed, without saving"
    option :verbose, aliases: "-v", desc: "Verbose output",
                     type: :boolean, default: false
    def remove(input_path, output_path)
      doc = load_document(input_path)
      removed = run_removal(doc)
      report_removal(doc, removed, output_path)
    rescue Uniword::Error => e
      handle_error(e)
    rescue StandardError => e
      handle_error(e, verbose: options[:verbose])
    end

    desc "rename FILE OUTPUT", "Rename a style's display name"
    long_desc <<~DESC
      Rename a style's display name (w:name) — Word's style rename.
      References target the styleId, so renamed styles stay linked from
      all content. Identify the style by --id (w:styleId) or --from
      (current display name).

      Examples:
        $ uniword styles rename input.docx output.docx --id Heading1 --name "Chapter Title"
        $ uniword styles rename input.docx output.docx --from "Old Name" --name "New Name"
    DESC
    option :id, type: :string, desc: "Style id (w:styleId) to rename"
    option :from, type: :string, desc: "Current display name of the style"
    option :name, type: :string, required: true, desc: "New display name"
    option :verbose, aliases: "-v", desc: "Verbose output",
                     type: :boolean, default: false
    def rename(input_path, output_path)
      identifier = rename_identifier
      doc = load_document(input_path)
      perform_rename(doc, identifier, output_path)
    rescue Uniword::Error, StandardError => e
      handle_error(e, verbose: options[:verbose])
    end

    private

    def rename_identifier
      identifier = options[:id] || options[:from]
      return identifier if identifier

      say "Error: specify --id or --from to identify the style", :red
      exit 1
    end

    def perform_rename(doc, identifier, output_path)
      unless doc.rename_style(identifier, options[:name])
        say "Style '#{identifier}' not found", :yellow
        exit 1
      end

      doc.save(output_path)
      say "Renamed style '#{identifier}' to '#{options[:name]}' " \
          "in #{output_path}", :green
    end

    def run_removal(doc)
      cleanup = Wordprocessingml::StyleCleanup.new(doc)
      removal_error unless options[:unused] || options[:id]

      removed_ids(cleanup)
    end

    def removed_ids(cleanup)
      if options[:unused]
        options[:dry_run] ? cleanup.unused_ids : cleanup.remove_unused
      else
        [options[:id]].select { |id| options[:dry_run] || cleanup.remove?(id) }
      end
    end

    def removal_error
      say "Error: specify --id or --unused", :red
      exit 1
    end

    def report_removal(doc, removed, output_path)
      if removed.empty?
        say "No styles removed.", :yellow
        return
      end

      verb = options[:dry_run] ? "Would remove" : "Removed"
      say "#{verb} #{removed.size} style(s): #{removed.join(', ')}", :green
      return if options[:dry_run]

      doc.save(output_path)
      say "Saved to #{output_path}", :green
    end

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
