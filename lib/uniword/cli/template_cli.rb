# frozen_string_literal: true

require "thor"
require "json"
require "yaml"
require_relative "helpers"

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
          say "    Description: #{t[:description] || "(none)"}"
          say "    Source: #{t[:source] || "(unknown)"}"
          say "    Markers: #{t[:markers] || 0}"
          say "    Created: #{t[:created_at] || "(unknown)"}"
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

      say "Creating template '#{name}' from #{source}...", :green if options[:verbose]

      metadata = Uniword::TemplateManager.create(
        name,
        source,
        options[:dir],
        description: options[:description]
      )

      say "Created template '#{name}' in #{options[:dir]}/", :green

      if options[:verbose]
        say "  Description: #{metadata[:description] || "(none)"}", :cyan
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
      say "  Data keys: #{data.keys.join(", ")}", :cyan if options[:verbose] && data.any?

      Uniword::TemplateManager.apply(
        template_name,
        data,
        output_path,
        template_dir: options[:dir]
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

    private

    def load_template_data
      data = {}

      if options[:data]
        data = parse_data_file(options[:data])
      end

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
  end
end
