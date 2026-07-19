# frozen_string_literal: true

require "thor"

module Uniword
  # Theme subcommands for Uniword CLI.
  #
  # Manages bundled and imported themes -- colors, fonts, and visual styling
  # that control document appearance.
  class ThemeCLI < Thor
    include CLIHelpers

    desc "list", "List all available bundled themes"
    long_desc <<~DESC
      Display all themes that are bundled with uniword.

      Examples:
        $ uniword theme list
        $ uniword theme list --verbose
    DESC
    option :verbose, aliases: "-v", desc: "Show detailed information", type: :boolean,
                     default: false
    def list
      themes = Themes::Theme.available_themes

      if themes.empty?
        say "No bundled themes found.", :yellow
        say "Run 'uniword theme import' to import Office themes.", :yellow
        return
      end

      say "Available themes (#{themes.count}):", :green
      themes.each do |theme_name|
        if options[:verbose]
          begin
            friendly = Themes::Theme.load(theme_name)
            say "  #{theme_name}:", :cyan
            say "    Name: #{friendly.name}"
            say "    Colors: #{friendly.color_scheme&.colors&.count || 0}"
            say "    Variants: #{friendly.variants&.count || 0}"
          rescue StandardError => e
            say "  #{theme_name}: Error loading - #{e.message}", :red
          end
        else
          say "  - #{theme_name}"
        end
      end
    end

    desc "import", "Import .thmx files to YAML theme library"
    long_desc <<~DESC
      Import Office theme (.thmx) files to YAML format for bundling with gem.

      Examples:
        $ uniword theme import
        $ uniword theme import --source themes/ --output data/themes
    DESC
    option :source, type: :string, default: "references/word-package/office-themes",
                    desc: "Source directory with .thmx files"
    option :output, type: :string, default: "data/themes",
                    desc: "Output directory for YAML files"
    option :verbose, aliases: "-v", desc: "Verbose output", type: :boolean,
                     default: false
    def import
      if options[:verbose]
        say "Importing themes from #{options[:source]}...",
            :green
      end

      importer = Themes::ThemeImporter.new
      count = importer.import_all(options[:source], options[:output])

      say "Successfully imported #{count} themes to #{options[:output]}/",
          :green

      if options[:verbose]
        themes = Dir.glob(File.join(options[:output], "*.yml")).map do |f|
          File.basename(f, ".yml")
        end.sort
        say "\nAvailable themes:", :cyan
        themes.each { |name| say "  - #{name}" }
      end
    rescue StandardError => e
      say "Error importing themes: #{e.message}", :red
      exit 1
    end

    desc "apply INPUT OUTPUT", "Apply a theme to a document"
    long_desc <<~DESC
      Apply a theme to an existing document.

      You can apply either:
      - A bundled theme by name (e.g., 'meridian', 'corporate')
      - A .thmx theme file by path

      Examples:
        $ uniword theme apply input.docx output.docx --name atlas
        $ uniword theme apply input.docx output.docx --name atlas --variant 2
        $ uniword theme apply input.docx output.docx --file Atlas.thmx
    DESC
    option :name, type: :string,
                  desc: "Bundled theme name (e.g., meridian, corporate)"
    option :file, type: :string,
                  desc: "Path to .thmx theme file"
    option :variant, type: :string,
                     desc: "Theme variant (variant1, variant2, etc. or numeric 1, 2, etc.)"
    option :verbose, aliases: "-v", desc: "Verbose output", type: :boolean,
                     default: false
    def apply(input_path, output_path)
      unless options[:name] || options[:file]
        say "Error: Must specify either --name for bundled theme or --file for .thmx file",
            :red
        exit 1
      end

      if options[:name] && options[:file]
        say "Error: Cannot specify both --name and --file", :red
        exit 1
      end

      say "Loading document #{input_path}...", :green if options[:verbose]

      doc = load_document(input_path)

      if options[:verbose]
        say "  Loaded document:", :cyan
        say "    Paragraphs: #{doc.paragraphs.count}"
        say "    Current theme: #{doc.theme&.name || 'None'}"
      end

      apply_theme_to(doc)

      if options[:verbose]
        say "  Applied theme:", :cyan
        say "    Theme name: #{doc.theme.name}"
        say "    Colors: #{doc.theme.color_scheme.colors.keys.join(', ')}"
        say "    Major font: #{doc.theme.major_font}"
        say "    Minor font: #{doc.theme.minor_font}"
        say "    Available variants: #{doc.theme.variants.keys.join(', ')}" if doc.theme.variants.any?
      end

      doc.save(output_path)
      say "Theme applied successfully to #{output_path}", :green
    rescue Uniword::Error => e
      handle_error(e)
    rescue StandardError => e
      handle_error(e, verbose: options[:verbose])
    end

    desc "fonts INPUT OUTPUT", "Apply a bundled font scheme to a document"
    long_desc <<~DESC
      Replace the document theme's font scheme (major/minor fonts) while
      keeping colors and formats — the equivalent of Word's Design →
      Fonts gallery. Use --list to see available font schemes.

      Examples:
        $ uniword theme fonts input.docx output.docx --name carlito_sans
        $ uniword theme fonts --list
    DESC
    option :name, type: :string,
                  desc: "Bundled font scheme name (e.g., carlito_sans)"
    option :list, type: :boolean, default: false,
                  desc: "List available bundled font schemes"
    option :verbose, aliases: "-v", desc: "Verbose output", type: :boolean,
                     default: false
    def fonts(*args)
      run_scheme_command(:fonts, args)
    end

    desc "colors INPUT OUTPUT", "Apply a bundled color scheme to a document"
    long_desc <<~DESC
      Replace the document theme's color scheme while keeping fonts and
      formats — the equivalent of Word's Design → Colors gallery. Use
      --list to see available color schemes.

      Examples:
        $ uniword theme colors input.docx output.docx --name emerald
        $ uniword theme colors --list
    DESC
    option :name, type: :string,
                  desc: "Bundled color scheme name (e.g., emerald)"
    option :list, type: :boolean, default: false,
                  desc: "List available bundled color schemes"
    option :verbose, aliases: "-v", desc: "Verbose output", type: :boolean,
                     default: false
    def colors(*args)
      run_scheme_command(:colors, args)
    end

    desc "auto INPUT OUTPUT", "Auto-transition MS theme to Uniword equivalent"
    long_desc <<~DESC
      Detect the Microsoft Word theme in a document and automatically
      replace it with the corresponding Uniword theme.

      Examples:
        $ uniword theme auto ms_report.docx uniword_report.docx
        $ uniword theme auto input.docx output.docx --verbose
    DESC
    option :verbose, aliases: "-v", desc: "Verbose output", type: :boolean,
                     default: false
    def auto(input_path, output_path)
      say "Loading document #{input_path}...", :green if options[:verbose]

      doc = load_document(input_path)

      if options[:verbose]
        say "  Loaded document:", :cyan
        say "    Current theme: #{doc.theme&.name || 'None'}"
      end

      result = doc.auto_transition_theme

      if result
        say "Transitioned MS '#{result.ms_name}' to Uniword '#{result.uniword_slug}'",
            :green
        if options[:verbose]
          friendly = Themes::Theme.load(result.uniword_slug)
          say "  Uniword theme:", :cyan
          say "    Name: #{friendly.name}"
          say "    Major font: #{friendly.font_scheme.major_font}"
          say "    Minor font: #{friendly.font_scheme.minor_font}"
        end
      else
        say "No matching Uniword theme found for this document's theme", :yellow
      end

      doc.save(output_path)
      say "Saved to #{output_path}", :green
    rescue Uniword::Error => e
      handle_error(e)
    rescue StandardError => e
      handle_error(e, verbose: options[:verbose])
    end

    # Scheme-switching command configuration: loader, document method,
    # and output label per command kind.
    SCHEME_COMMANDS = {
      fonts: {
        loader: Resource::FontSchemeLoader,
        doc_method: :apply_font_scheme,
        label: "Font scheme",
      },
      colors: {
        loader: Resource::ColorSchemeLoader,
        doc_method: :apply_color_scheme,
        label: "Color scheme",
      },
    }.freeze

    private

    def run_scheme_command(kind, args)
      config = SCHEME_COMMANDS.fetch(kind)
      if options[:list]
        config[:loader].available_schemes.each { |s| say s }
        return
      end

      require_name!(:name, config[:loader])
      apply_scheme_to_file(config, args)
    rescue Uniword::Error => e
      handle_error(e)
    rescue StandardError => e
      handle_error(e, verbose: options[:verbose])
    end

    def apply_scheme_to_file(config, (input_path, output_path))
      say "Loading document #{input_path}...", :green if options[:verbose]

      doc = load_document(input_path)
      doc.method(config[:doc_method]).call(options[:name])
      doc.save(output_path)
      say "#{config[:label]} '#{options[:name]}' applied to #{output_path}",
          :green
    end

    def require_name!(key, loader)
      return if options[key]

      say "Error: specify --name for a bundled scheme " \
          "(available: #{loader.available_schemes.join(', ')})", :red
      exit 1
    end

    def apply_theme_to(doc)
      if options[:name]
        if options[:verbose]
          say "Applying bundled theme '#{options[:name]}'...",
              :green
        end
        doc.apply_theme(options[:name], variant: options[:variant])
      else
        unless File.exist?(options[:file])
          say "Theme file not found: #{options[:file]}", :red
          exit 1
        end
        if options[:verbose]
          say "Applying theme from #{options[:file]}...",
              :green
        end
        doc.apply_theme_file(options[:file], variant: options[:variant])
      end
    rescue ArgumentError => e
      say "Error applying theme: #{e.message}", :red
      exit 1
    end
  end
end
