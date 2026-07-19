# frozen_string_literal: true

require "thor"

module Uniword
  # Page subcommands for Uniword CLI.
  #
  # Uniform page setup across a document — the CLI equivalent of Word's
  # Layout dialog (size, orientation, margins).
  class PageCLI < Thor
    include CLIHelpers

    desc "setup INPUT OUTPUT", "Apply page setup to every section"
    long_desc <<~DESC
      Apply uniform page setup — paper size, orientation, and margins —
      to every section of a document, the CLI equivalent of Word's
      Layout dialog.

      Examples:
        $ uniword page setup input.docx output.docx --size a4
        $ uniword page setup input.docx output.docx --size a4 --orientation landscape
        $ uniword page setup input.docx output.docx --margins 1in
        $ uniword page setup input.docx output.docx --margins 2.5cm --margin-top 3cm
    DESC
    option :size, type: :string,
                  desc: "Paper size: letter, legal, a4, a5, executive"
    option :orientation, type: :string,
                         desc: "portrait or landscape"
    option :margins, type: :string,
                     desc: "Uniform margin for all sides " \
                           "(1in, 2.5cm, 25mm, 1440)"
    option :margin_top, type: :string, desc: "Top margin override"
    option :margin_right, type: :string, desc: "Right margin override"
    option :margin_bottom, type: :string, desc: "Bottom margin override"
    option :margin_left, type: :string, desc: "Left margin override"
    option :verbose, aliases: "-v", desc: "Verbose output", type: :boolean,
                     default: false
    def setup(input_path, output_path)
      opts = setup_options
      unless opts
        say "Error: specify at least one of --size, --orientation, " \
            "--margins, --margin-top/right/bottom/left", :red
        exit 1
      end

      say "Loading document #{input_path}...", :green if options[:verbose]

      sections = apply_setup(input_path, output_path, opts)
      say "Page setup applied to #{sections} section(s) in #{output_path}",
          :green
    rescue Uniword::Error => e
      handle_error(e)
    rescue StandardError => e
      handle_error(e, verbose: options[:verbose])
    end

    private

    def setup_options
      map = base_setup_options.merge(margin_setup_options)
      map unless map.values.all?(&:nil?)
    end

    def base_setup_options
      {
        size: options[:size], orientation: options[:orientation],
        margins: options[:margins]
      }
    end

    def margin_setup_options
      {
        top: options[:margin_top], right: options[:margin_right],
        bottom: options[:margin_bottom], left: options[:margin_left]
      }
    end

    def apply_setup(input_path, output_path, opts)
      doc = load_document(input_path)
      sections = doc.apply_page_setup(**opts)
      doc.save(output_path)
      sections
    end
  end
end
