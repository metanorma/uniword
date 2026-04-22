# frozen_string_literal: true

require "thor"
require_relative "helpers"

module Uniword
  # StyleSet subcommands for Uniword CLI.
  #
  # Manages bundled and imported StyleSets -- collections of paragraph,
  # character, and table styles that provide consistent formatting.
  class StyleSetCLI < Thor
    include CLIHelpers

    desc "list", "List all available bundled StyleSets"
    long_desc <<~DESC
      Display all StyleSets that are bundled with uniword.

      Examples:
        $ uniword styleset list
        $ uniword styleset list --verbose
    DESC
    option :verbose, aliases: "-v", desc: "Show detailed information", type: :boolean,
                     default: false
    def list
      stylesets = StyleSet.available_stylesets

      if stylesets.empty?
        say "No bundled StyleSets found.", :yellow
        say "Run 'uniword styleset import' to import .dotx StyleSets.", :yellow
        return
      end

      say "Available StyleSets (#{stylesets.count}):", :green
      stylesets.each do |styleset_name|
        if options[:verbose]
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

    desc "import", "Import .dotx files to YAML StyleSet library"
    long_desc <<~DESC
      Import .dotx StyleSet files to YAML format for bundling with gem.

      Examples:
        $ uniword styleset import
        $ uniword styleset import --source stylesets/ --output data/stylesets
    DESC
    option :source, type: :string, default: "references/word-package/style-sets",
                    desc: "Source directory with .dotx files"
    option :output, type: :string, default: "data/stylesets",
                    desc: "Output directory for YAML files"
    option :verbose, aliases: "-v", desc: "Verbose output", type: :boolean, default: false
    def import
      say "Importing StyleSet from #{options[:source]}...", :green if options[:verbose]

      importer = Stylesets::StyleSetImporter.new
      count = importer.import_all(options[:source], options[:output])

      say "Successfully imported #{count} StyleSets to #{options[:output]}/", :green

      if options[:verbose]
        stylesets = Dir.glob(File.join(options[:output], "*.yml")).map do |f|
          File.basename(f, ".yml")
        end.sort
        say "\nAvailable StyleSets:", :cyan
        stylesets.each { |name| say "  - #{name}" }
      end
    rescue StandardError => e
      say "Error importing StyleSet: #{e.message}", :red
      exit 1
    end

    desc "apply INPUT OUTPUT", "Apply a StyleSet to a document"
    long_desc <<~DESC
      Apply a StyleSet to an existing document.

      You can apply either:
      - A bundled StyleSet by name (e.g., 'signature', 'heritage')
      - A .dotx StyleSet file by path

      Examples:
        $ uniword styleset apply input.docx output.docx --name distinctive
        $ uniword styleset apply input.docx output.docx --file Distinctive.dotx
    DESC
    option :name, type: :string,
                  desc: "Bundled StyleSet name (e.g., signature, heritage)"
    option :file, type: :string,
                  desc: "Path to .dotx StyleSet file"
    option :strategy, type: :string, default: "keep_existing",
                      desc: "Application strategy (keep_existing, replace, rename)"
    option :verbose, aliases: "-v", desc: "Verbose output", type: :boolean, default: false
    def apply(input_path, output_path)
      unless options[:name] || options[:file]
        say "Error: Must specify either --name for bundled StyleSet or --file for .dotx file",
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
        say "    Current styles: #{doc.styles.count}"
      end

      apply_styleset_to(doc)

      if options[:verbose]
        say "  Applied StyleSet:", :cyan
        say "    Total styles: #{doc.styles.count}"
        say "    Strategy: #{options[:strategy]}"
      end

      doc.save(output_path)
      say "StyleSet applied successfully to #{output_path}", :green
    rescue Uniword::Error => e
      handle_error(e)
    rescue StandardError => e
      handle_error(e, verbose: options[:verbose])
    end

    desc "extract DOCX", "Extract styles from a DOCX into YAML StyleSet"
    option :name, required: true, desc: "StyleSet name"
    option :output, desc: "Output YAML file"
    def extract(docx_path)
      output = options[:output] ||
               "data/stylesets/#{options[:name]}.yml"
      Generation::StyleExtractor.extract_to_yaml(docx_path, output)
      say("StyleSet extracted: #{output}", :green)
    rescue Uniword::Error => e
      handle_error(e)
    rescue StandardError => e
      handle_error(e)
    end

    private

    def apply_styleset_to(doc)
      strategy = options[:strategy].to_sym

      if options[:name]
        say "Applying bundled StyleSet '#{options[:name]}'...", :green if options[:verbose]
        doc.apply_styleset(options[:name], strategy: strategy)
      else
        unless File.exist?(options[:file])
          say "StyleSet file not found: #{options[:file]}", :red
          exit 1
        end
        say "Applying StyleSet from #{options[:file]}...", :green if options[:verbose]
        styleset = StyleSet.from_dotx(options[:file])
        styleset.apply_to(doc, strategy: strategy)
      end
    rescue ArgumentError => e
      say "Error applying StyleSet: #{e.message}", :red
      exit 1
    end
  end
end
