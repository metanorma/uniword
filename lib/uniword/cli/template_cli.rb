# frozen_string_literal: true

require "thor"
require "json"
require "yaml"

module Uniword
  # Template subcommands for Uniword CLI.
  #
  # Manages a library of .docx template files -- create templates from
  # existing documents, list the library, and apply templates with data
  # to generate new documents.
  #
  # Uses TemplateCLI (not Template) to avoid collision with the
  # Uniword::Template module.
  class TemplateCLI < Thor
    include CLIHelpers

    desc "list", "List available templates"
    long_desc <<~DESC
      Display all templates in the template library directory.

      Examples:
        $ uniword template list
        $ uniword template list --dir my_templates
        $ uniword template list -v
    DESC
    option :dir, default: "templates",
                 desc: "Template library directory"
    option :verbose, aliases: "-v", desc: "Show detailed information",
                     type: :boolean, default: false
    def list
      templates = Uniword::TemplateManager.list(options[:dir])

      if templates.empty?
        say "No templates found in #{options[:dir]}/", :yellow
        say "Use 'uniword template create' to add templates.", :yellow
        return
      end

      say "Available templates (#{templates.count}):", :green
      templates.each do |t|
        if options[:verbose]
          say "  #{t[:name]}:", :cyan
          say "    Path: #{t[:path]}"
          say "    Description: #{t[:description] || '(none)'}"
          say "    Source: #{t[:source] || '(unknown)'}"
          say "    Markers: #{t[:markers] || 0}"
          say "    Created: #{t[:created_at] || '(unknown)'}"
        else
          label = t[:description] ? " - #{t[:description]}" : ""
          say "  - #{t[:name]}#{label}"
        end
      end
    rescue StandardError => e
      handle_error(e, verbose: options[:verbose])
    end

    desc "create NAME SOURCE", "Create template from existing DOCX"
    long_desc <<~DESC
      Copy an existing DOCX file into the template library with metadata.

      Examples:
        $ uniword template create report report.docx
        $ uniword template create letter template.docx --dir templates
        $ uniword template create report report.docx --description "Annual report"
    DESC
    option :dir, default: "templates",
                 desc: "Template library directory"
    option :description, type: :string,
                         desc: "Template description"
    option :verbose, aliases: "-v", desc: "Verbose output",
                     type: :boolean, default: false
    def create(name, source)
      unless File.exist?(source)
        say "Source file not found: #{source}", :red
        exit 1
      end

      if options[:verbose]
        say "Creating template '#{name}' from #{source}...",
            :green
      end

      metadata = Uniword::TemplateManager.create(
        name,
        source,
        options[:dir],
        description: options[:description],
      )

      say "Created template '#{name}' in #{options[:dir]}/", :green

      if options[:verbose]
        say "  Description: #{metadata[:description] || '(none)'}", :cyan
        say "  Markers: #{metadata[:markers]}", :cyan
        say "  Created: #{metadata[:created_at]}", :cyan
      end
    rescue ArgumentError => e
      say "Error: #{e.message}", :red
      exit 1
    rescue Uniword::Error => e
      handle_error(e)
    rescue StandardError => e
      handle_error(e, verbose: options[:verbose])
    end

    desc "apply TEMPLATE OUTPUT", "Apply template with data"
    long_desc <<~DESC
      Fill a template with data and save the result as a new DOCX file.

      Data can be provided via a YAML/JSON file (--data) or inline
      key=value pairs (--set), or both.

      Examples:
        $ uniword template apply report output.docx --data data.yml
        $ uniword template apply report output.docx --data data.json
        $ uniword template apply letter out.docx --set title="Hello" --set name="World"
        $ uniword template apply report out.docx --data data.yml --set author="Jane"
    DESC
    option :data, desc: "Path to YAML or JSON data file", type: :string
    option :dir, default: "templates",
                 desc: "Template library directory"
    option "set", type: :array, default: [],
                  desc: "Set variable (key=value), may be repeated"
    option :verbose, aliases: "-v", desc: "Verbose output",
                     type: :boolean, default: false
    def apply(template_name, output_path)
      data = load_template_data

      say "Applying template '#{template_name}'...", :green if options[:verbose]
      if options[:verbose] && data.any?
        say "  Data keys: #{data.keys.join(', ')}",
            :cyan
      end

      Uniword::TemplateManager.apply(
        template_name,
        data,
        output_path,
        template_dir: options[:dir],
      )

      say "Applied template '#{template_name}' -> #{output_path}", :green
    rescue ArgumentError => e
      say "Error: #{e.message}", :red
      exit 1
    rescue Uniword::Error => e
      handle_error(e)
    rescue StandardError => e
      handle_error(e, verbose: options[:verbose])
    end

    desc "fill DOCUMENT", "Fill placeholders in a document with data"
    long_desc <<~DESC
      Fill placeholders in a DOCX document (mail merge) and save the
      result as a new DOCX file.

      Placeholder sources, in precedence order:
        1. Content controls (w:sdt) whose alias or tag names a variable
        2. MERGEFIELD simple fields (w:fldSimple)
        3. {{var}} text placeholders inside run text

      Data is loaded from a YAML or JSON file (--data, required). Nested
      data keys are addressed with dotted paths ({{client.name}}).
      Placeholders without data are left untouched unless --strict,
      which fails with the list of missing variable names.

      Examples:
        $ uniword template fill letter.docx --data data.yml
        $ uniword template fill letter.docx --data data.json -o out.docx
        $ uniword template fill letter.docx --data data.yml --strict
        $ uniword template fill letter.docx --data data.yml --json
    DESC
    option :data, desc: "Path to YAML or JSON data file", type: :string,
                  required: true
    option :output, aliases: "-o",
                    desc: "Output DOCX path (default: <name>.filled.docx)",
                    type: :string
    option :strict, desc: "Fail when a placeholder variable has no data",
                    type: :boolean, default: false
    option :json, desc: "Report as JSON", type: :boolean, default: false
    option :verbose, aliases: "-v", desc: "Verbose output",
                     type: :boolean, default: false
    def fill(input_path)
      validate_input_file(input_path)

      document = DocumentFactory.from_file(input_path)
      data = parse_data_file(options[:data])
      log_fill_start(data) if options[:verbose]
      report_fill(document, data, input_path)
    rescue Uniword::Error => e
      handle_error(e)
    rescue StandardError => e
      handle_error(e, verbose: options[:verbose])
    end

    private

    def validate_input_file(path)
      return if File.exist?(path)

      say "File not found: #{path}", :red
      exit 1
    end

    def log_fill_start(data)
      return unless data.any?

      say "  Data keys: #{data.keys.join(', ')}", :cyan
    end

    def report_fill(document, data, input_path)
      result = fill_document(document, data)
      output_path = options[:output] || derive_filled_path(input_path)
      document.save(output_path)

      if options[:json]
        puts result.to_json
      else
        say result.summary, result.complete? ? :green : :yellow
        say "Filled document -> #{output_path}", :green
      end
    end

    def fill_document(document, data)
      Uniword::Template::Filler.new(document)
        .fill(data, strict: options[:strict])
    end

    def load_template_data
      data = {}

      data = parse_data_file(options[:data]) if options[:data]

      merge_set_options(data)
    end

    def parse_data_file(path)
      unless File.exist?(path)
        say "Data file not found: #{path}", :red
        exit 1
      end

      content = File.read(path)
      ext = File.extname(path).downcase

      case ext
      when ".json"
        JSON.parse(content)
      when ".yml", ".yaml"
        YAML.safe_load(content) || {}
      else
        say "Unsupported data format: #{ext}. Use .yml, .yaml, or .json", :red
        exit 1
      end
    end

    def merge_set_options(data)
      options["set"].each do |pair|
        key, value = pair.split("=", 2)
        data[key] = value if key && value
      end

      data
    end

    # Default output path: "<name>.filled.docx" next to the input.
    def derive_filled_path(path)
      ext = File.extname(path)
      "#{path.delete_suffix(ext)}.filled#{ext}"
    end
  end
end
