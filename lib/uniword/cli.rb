# frozen_string_literal: true

require 'thor'
require_relative 'document_factory'
require_relative 'document_writer'
require_relative 'format_detector'
require_relative 'errors'

module Uniword
  # StyleSet subcommands for Uniword CLI
  class StyleSetCLI < Thor
    # Error handling for all commands
    def self.exit_on_failure?
      true
    end

    desc 'list', 'List all available bundled StyleSets'
    long_desc <<~DESC
      Display all StyleSets that are bundled with uniword.

      These StyleSets can be loaded using StyleSet.load(name) or doc.apply_styleset(name).

      Examples:
        $ uniword styleset list
        $ uniword styleset list --verbose
    DESC
    option :verbose, aliases: '-v', desc: 'Show detailed information', type: :boolean,
                     default: false
    def list
      require_relative 'styleset'

      stylesets = StyleSet.available_stylesets

      if stylesets.empty?
        say 'No bundled StyleSets found.', :yellow
        say "Run 'uniword styleset import' to import .dotx StyleSets.", :yellow
        return
      end

      say "Available StyleSets (#{stylesets.count}):", :green
      stylesets.each do |styleset_name|
        if options[:verbose]
          # Load StyleSet to show details
          begin
            styleset = StyleSet.load(styleset_name)
            say "  #{styleset_name}:", :cyan
            say "    Name: #{styleset.name}"
            say "    Styles: #{styleset.styles.count}"
            say "    Paragraph styles: #{styleset.paragraph_styles.count}"
            say "    Character styles: #{styleset.character_styles.count}"
            say "    Table styles: #{styleset.table_styles.count}"
          rescue StandardError => e
            say "  #{styleset_name}: Error loading - #{e.message}", :red
          end
        else
          say "  - #{styleset_name}"
        end
      end
    end

    desc 'import', 'Import .dotx files to YAML StyleSet library'
    long_desc <<~DESC
      Import .dotx StyleSet files to YAML format for bundling with gem.

      The YAML format is human-readable, faster to load, and easier to customize.

      Examples:
        $ uniword styleset import
        $ uniword styleset import --source stylesets/ --output data/stylesets
    DESC
    option :source, type: :string, default: 'references/word-package/style-sets',
                    desc: 'Source directory with .dotx files'
    option :output, type: :string, default: 'data/stylesets',
                    desc: 'Output directory for YAML files'
    option :verbose, aliases: '-v', desc: 'Verbose output', type: :boolean, default: false
    def import
      require_relative 'stylesets/styleset_importer'

      say "Importing StyleSets from #{options[:source]}...", :green if options[:verbose]

      importer = StyleSets::StyleSetImporter.new
      count = importer.import_all(options[:source], options[:output])

      say "Successfully imported #{count} StyleSets to #{options[:output]}/", :green

      if options[:verbose]
        stylesets = Dir.glob(File.join(options[:output], '*.yml')).map do |f|
          File.basename(f, '.yml')
        end.sort
        say "\nAvailable StyleSets:", :cyan
        stylesets.each { |name| say "  - #{name}" }
      end
    rescue StandardError => e
      say "Error importing StyleSets: #{e.message}", :red
      exit 1
    end

    desc 'apply INPUT OUTPUT', 'Apply a StyleSet to a document'
    long_desc <<~DESC
      Apply a StyleSet to an existing document.

      You can apply either:
      - A bundled StyleSet by name (e.g., 'distinctive', 'basic')
      - A .dotx StyleSet file by path

      StyleSets contain collections of paragraph, character, and table styles
      that provide consistent formatting for documents.

      Examples:
        $ uniword styleset apply input.docx output.docx --name distinctive
        $ uniword styleset apply input.docx output.docx --name distinctive --verbose
        $ uniword styleset apply input.docx output.docx --file Distinctive.dotx
    DESC
    option :name, type: :string,
                  desc: 'Bundled StyleSet name (e.g., distinctive, basic)'
    option :file, type: :string,
                  desc: 'Path to .dotx StyleSet file'
    option :strategy, type: :string, default: 'keep_existing',
                      desc: 'Application strategy (keep_existing, replace, rename)'
    option :verbose, aliases: '-v', desc: 'Verbose output', type: :boolean, default: false
    def apply(input_path, output_path)
      require_relative 'document'

      # Validate that either --name or --file is provided
      unless options[:name] || options[:file]
        say '✗ Error: Must specify either --name for bundled StyleSet or --file for .dotx file',
            :red
        exit 1
      end

      if options[:name] && options[:file]
        say '✗ Error: Cannot specify both --name and --file', :red
        exit 1
      end

      say "Loading document #{input_path}...", :green if options[:verbose]

      # Load input document
      doc = DocumentFactory.from_file(input_path)

      if options[:verbose]
        say '  Loaded document:', :cyan
        say "    Paragraphs: #{doc.paragraphs.count}"
        say "    Current styles: #{doc.styles.count}"
      end

      # Apply StyleSet
      begin
        if options[:name]
          # Apply bundled StyleSet
          say "Applying bundled StyleSet '#{options[:name]}'...", :green if options[:verbose]
          strategy = options[:strategy].to_sym
          doc.apply_styleset(options[:name], strategy: strategy)
        else
          # Apply .dotx file
          unless File.exist?(options[:file])
            say "✗ StyleSet file not found: #{options[:file]}", :red
            exit 1
          end
          say "Applying StyleSet from #{options[:file]}...", :green if options[:verbose]
          styleset = StyleSet.from_dotx(options[:file])
          strategy = options[:strategy].to_sym
          styleset.apply_to(doc, strategy: strategy)
        end

        if options[:verbose]
          say '  Applied StyleSet:', :cyan
          say "    Total styles: #{doc.styles.count}"
          say "    Strategy: #{options[:strategy]}"
        end
      rescue ArgumentError => e
        say "✗ Error applying StyleSet: #{e.message}", :red
        exit 1
      end

      # Save output document
      doc.save(output_path)

      say "StyleSet applied successfully to #{output_path}", :green
    rescue Uniword::Error => e
      say "Error: #{e.message}", :red
      exit 1
    rescue StandardError => e
      say "Unexpected error: #{e.message}", :red
      say e.backtrace.join("\n"), :red if options[:verbose]
      exit 1
    end
  end

  # Theme subcommands for Uniword CLI
  class ThemeCLI < Thor
    # Error handling for all commands
    def self.exit_on_failure?
      true
    end

    desc 'list', 'List all available bundled themes'
    long_desc <<~DESC
      Display all themes that are bundled with uniword.

      These themes can be loaded using Theme.load(name) or doc.apply_theme(name).

      Examples:
        $ uniword theme list
        $ uniword theme list --verbose
    DESC
    option :verbose, aliases: '-v', desc: 'Show detailed information', type: :boolean,
                     default: false
    def list
      require_relative 'theme'

      themes = Theme.available_themes

      if themes.empty?
        say 'No bundled themes found.', :yellow
        say "Run 'uniword theme import' to import Office themes.", :yellow
        return
      end

      say "Available themes (#{themes.count}):", :green
      themes.each do |theme_name|
        if options[:verbose]
          # Load theme to show details
          begin
            theme = Theme.load(theme_name)
            say "  #{theme_name}:", :cyan
            say "    Name: #{theme.name}"
            say "    Colors: #{theme.color_scheme.colors.count}"
            say "    Variants: #{theme.variants.count}"
          rescue StandardError => e
            say "  #{theme_name}: Error loading - #{e.message}", :red
          end
        else
          say "  - #{theme_name}"
        end
      end
    end

    desc 'import', 'Import .thmx files to YAML theme library'
    long_desc <<~DESC
      Import Office theme (.thmx) files to YAML format for bundling with gem.

      The YAML format is human-readable, faster to load, and easier to customize.

      Examples:
        $ uniword theme import
        $ uniword theme import --source themes/ --output data/themes
    DESC
    option :source, type: :string, default: 'references/word-package/office-themes',
                    desc: 'Source directory with .thmx files'
    option :output, type: :string, default: 'data/themes',
                    desc: 'Output directory for YAML files'
    option :verbose, aliases: '-v', desc: 'Verbose output', type: :boolean, default: false
    def import
      require_relative 'themes/theme_importer'

      say "Importing themes from #{options[:source]}...", :green if options[:verbose]

      importer = Themes::ThemeImporter.new
      count = importer.import_all(options[:source], options[:output])

      say "Successfully imported #{count} themes to #{options[:output]}/", :green

      if options[:verbose]
        themes = Dir.glob(File.join(options[:output], '*.yml')).map do |f|
          File.basename(f, '.yml')
        end.sort
        say "\nAvailable themes:", :cyan
        themes.each { |name| say "  - #{name}" }
      end
    rescue StandardError => e
      say "Error importing themes: #{e.message}", :red
      exit 1
    end

    desc 'apply INPUT OUTPUT', 'Apply a theme to a document'
    long_desc <<~DESC
      Apply a theme to an existing document.

      You can apply either:
      - A bundled theme by name (e.g., 'atlas', 'office_theme')
      - A .thmx theme file by path

      Themes control the document's colors, fonts, and visual styling.
      You can optionally apply a specific theme variant for different
      visual styles.

      Examples:
        $ uniword theme apply input.docx output.docx --name atlas
        $ uniword theme apply input.docx output.docx --name atlas --variant 2
        $ uniword theme apply input.docx output.docx --file Atlas.thmx
        $ uniword theme apply input.docx output.docx --file themes/Office.thmx --variant 2
    DESC
    option :name, type: :string,
                  desc: 'Bundled theme name (e.g., atlas, office_theme)'
    option :file, type: :string,
                  desc: 'Path to .thmx theme file'
    option :variant, type: :string,
                     desc: 'Theme variant (variant1, variant2, etc. or numeric 1, 2, etc.)'
    option :verbose, aliases: '-v', desc: 'Verbose output', type: :boolean, default: false
    def apply(input_path, output_path)
      require_relative 'document'

      # Validate that either --name or --file is provided
      unless options[:name] || options[:file]
        say '✗ Error: Must specify either --name for bundled theme or --file for .thmx file', :red
        exit 1
      end

      if options[:name] && options[:file]
        say '✗ Error: Cannot specify both --name and --file', :red
        exit 1
      end

      say "Loading document #{input_path}...", :green if options[:verbose]

      # Load input document
      doc = DocumentFactory.from_file(input_path)

      if options[:verbose]
        say '  Loaded document:', :cyan
        say "    Paragraphs: #{doc.paragraphs.count}"
        say "    Current theme: #{doc.theme&.name || 'None'}"
      end

      # Apply theme
      begin
        if options[:name]
          # Apply bundled theme
          say "Applying bundled theme '#{options[:name]}'...", :green if options[:verbose]
          doc.apply_theme(options[:name], variant: options[:variant])
        else
          # Apply .thmx file
          unless File.exist?(options[:file])
            say "✗ Theme file not found: #{options[:file]}", :red
            exit 1
          end
          say "Applying theme from #{options[:file]}...", :green if options[:verbose]
          doc.apply_theme_file(options[:file], variant: options[:variant])
        end

        if options[:verbose]
          say '  Applied theme:', :cyan
          say "    Theme name: #{doc.theme.name}"
          say "    Colors: #{doc.theme.color_scheme.colors.keys.join(', ')}"
          say "    Major font: #{doc.theme.major_font}"
          say "    Minor font: #{doc.theme.minor_font}"
          if doc.theme.variants.any?
            say "    Available variants: #{doc.theme.variants.keys.join(', ')}"
          end
        end
      rescue ArgumentError => e
        say "✗ Error applying theme: #{e.message}", :red
        exit 1
      end

      # Save output document
      doc.save(output_path)

      say "Theme applied successfully to #{output_path}", :green
    rescue Uniword::Error => e
      say "Error: #{e.message}", :red
      exit 1
    rescue StandardError => e
      say "Unexpected error: #{e.message}", :red
      say e.backtrace.join("\n"), :red if options[:verbose]
      exit 1
    end
  end

  # Command-line interface for Uniword
  #
  # Provides commands for document conversion, inspection, and validation
  class CLI < Thor
    # Error handling for all commands
    def self.exit_on_failure?
      true
    end

    desc 'convert INPUT OUTPUT', 'Convert document between formats'
    long_desc <<~DESC
      Convert a document from one format to another.

      Supports automatic format detection based on file extensions,
      or you can specify formats explicitly with --from and --to options.

      Supported formats: DOCX, MHTML

      Examples:
        $ uniword convert input.docx output.mhtml
        $ uniword convert input.mhtml output.docx --verbose
        $ uniword convert input.doc output.docx --from doc --to docx
    DESC
    option :from, aliases: '-f', desc: 'Input format (docx/mhtml)', type: :string
    option :to, aliases: '-t', desc: 'Output format (docx/mhtml)', type: :string
    option :verbose, aliases: '-v', desc: 'Verbose output', type: :boolean, default: false
    def convert(input_path, output_path)
      from_format = options[:from]&.to_sym || :auto
      to_format = options[:to]&.to_sym || :auto

      say "Converting #{input_path} to #{output_path}...", :green if options[:verbose]

      # Load document
      doc = DocumentFactory.from_file(input_path, format: from_format)

      if options[:verbose]
        say '  Loaded document:', :cyan
        say "    Paragraphs: #{doc.paragraphs.count}"
        say "    Tables: #{doc.tables.count}"
        say "    Styles: #{doc.styles_configuration&.all_styles&.count || 0}"
      end

      # Save document
      doc.save(output_path, format: to_format)

      say 'Conversion complete!', :green if options[:verbose]
    rescue Uniword::Error => e
      say "Error: #{e.message}", :red
      exit 1
    rescue StandardError => e
      say "Unexpected error: #{e.message}", :red
      say e.backtrace.join("\n"), :red if options[:verbose]
      exit 1
    end

    desc 'info FILE', 'Display document information'
    long_desc <<~DESC
      Display detailed information about a document including:
      - Detected format
      - Number of paragraphs and tables
      - Text content length
      - Styles used
      - Document structure

      Examples:
        $ uniword info document.docx
        $ uniword info report.mhtml --verbose
    DESC
    option :verbose, aliases: '-v', desc: 'Show detailed information', type: :boolean,
                     default: false
    def info(path)
      say "Analyzing #{path}...", :green

      # Detect format
      detector = FormatDetector.new
      format = detector.detect(path)
      say "\nFormat: #{format.to_s.upcase}", :cyan

      # Load document
      doc = DocumentFactory.from_file(path)

      # Basic statistics
      say "\nDocument Statistics:", :cyan
      say "  Paragraphs: #{doc.paragraphs.count}"
      say "  Tables: #{doc.tables.count}"
      say "  Text length: #{doc.text.length} characters"

      # Styles information
      if doc.styles_configuration&.all_styles&.any?
        say "  Styles: #{doc.styles_configuration.all_styles.count}"
      end

      # Detailed information
      if options[:verbose]
        say "\nDetailed Information:", :cyan

        # Show first few paragraphs
        if doc.paragraphs.any?
          say '  First paragraphs:'
          doc.paragraphs.first(3).each_with_index do |para, i|
            text = para.text[0..80]
            text += '...' if para.text.length > 80
            say "    #{i + 1}. #{text}"
          end
        end

        # Show tables
        if doc.tables.any?
          say '  Tables:'
          doc.tables.each_with_index do |table, i|
            say "    #{i + 1}. #{table.row_count} rows × #{table.column_count} columns"
          end
        end
      end

      say "\nAnalysis complete!", :green
    rescue Uniword::Error => e
      say "Error: #{e.message}", :red
      exit 1
    rescue StandardError => e
      say "Unexpected error: #{e.message}", :red
      exit 1
    end

    desc 'validate FILE', 'Validate document structure'
    long_desc <<~DESC
      Validate a document's structure and check for common issues.

      Checks include:
      - File format integrity
      - Document structure validity
      - Element validation
      - Content completeness

      Examples:
        $ uniword validate document.docx
        $ uniword validate report.mhtml --verbose
    DESC
    option :verbose, aliases: '-v', desc: 'Show detailed validation results', type: :boolean,
                     default: false
    def validate(path)
      say "Validating #{path}...", :green

      # Check file exists
      unless File.exist?(path)
        say "✗ File not found: #{path}", :red
        exit 1
      end

      # Try to load document
      begin
        doc = DocumentFactory.from_file(path)
        say '✓ File format is valid', :green
      rescue Uniword::CorruptedFileError => e
        say "✗ File is corrupted: #{e.reason}", :red
        exit 1
      rescue Uniword::Error => e
        say "✗ Validation failed: #{e.message}", :red
        exit 1
      end

      # Validate document structure
      if doc.valid?
        say '✓ Document structure is valid', :green
      else
        say '✗ Document has structural issues', :yellow
      end

      # Check for content
      if doc.paragraphs.any? || doc.tables.any?
        say '✓ Document contains content', :green
      else
        say '⚠ Document appears to be empty', :yellow
      end

      # Detailed validation
      if options[:verbose]
        say "\nDetailed Validation:", :cyan

        # Check paragraphs
        empty_paras = doc.paragraphs.count(&:empty?)
        if empty_paras.positive?
          say "  ⚠ #{empty_paras} empty paragraph(s) found", :yellow
        else
          say '  ✓ All paragraphs have content', :green
        end

        # Check tables
        if doc.tables.any?
          empty_tables = doc.tables.count(&:empty?)
          if empty_tables.positive?
            say "  ⚠ #{empty_tables} empty table(s) found", :yellow
          else
            say '  ✓ All tables have content', :green
          end
        end
      end

      say "\nValidation complete!", :green
    rescue StandardError => e
      say "Unexpected error during validation: #{e.message}", :red
      exit 1
    end

    # Register theme subcommand
    desc 'theme SUBCOMMAND', 'Manage document themes'
    subcommand 'theme', ThemeCLI

    # Register styleset subcommand
    desc 'styleset SUBCOMMAND', 'Manage document StyleSets'
    subcommand 'styleset', StyleSetCLI

    desc 'version', 'Show Uniword version'
    def version
      require_relative 'version'
      say "Uniword version #{Uniword::VERSION}", :green
    end
  end
end
