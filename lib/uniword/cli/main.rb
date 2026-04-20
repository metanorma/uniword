# frozen_string_literal: true

require "thor"
require "rainbow"
require_relative "helpers"
require_relative "styleset_cli"
require_relative "resources_cli"
require_relative "theme_cli"
require_relative "generate_cli"
require_relative "review_cli"
require_relative "template_cli"
require_relative "diff_cli"
require_relative "toc_cli"
require_relative "images_cli"
require_relative "spellcheck_cli"
require_relative "headers_cli"
require_relative "watermark_cli"
require_relative "protect_cli"

module Uniword
  # Command-line interface for Uniword.
  #
  # Provides commands for document conversion, inspection, validation,
  # building, checking, batch processing, metadata, and verification.
  #
  # Subcommands:
  # - theme → ThemeCLI
  # - styleset → StyleSetCLI
  # - resources → ResourcesCLI
  class CLI < Thor
    include CLIHelpers

    desc "convert INPUT OUTPUT", "Convert document between formats"
    long_desc <<~DESC
      Convert a document from one format to another.

      Supported formats: DOCX, MHTML, HTML

      Examples:
        $ uniword convert input.docx output.mhtml
        $ uniword convert input.mhtml output.docx --verbose
        $ uniword convert input.html output.docx
    DESC
    option :from, aliases: "-f", desc: "Input format (docx/mhtml/html)", type: :string
    option :to, aliases: "-t", desc: "Output format (docx/mhtml)", type: :string
    option :verbose, aliases: "-v", desc: "Verbose output", type: :boolean, default: false
    def convert(input_path, output_path)
      from_format = options[:from]&.to_sym || :auto
      to_format = options[:to]&.to_sym || :auto

      say "Converting #{input_path} to #{output_path}...", :green if options[:verbose]

      doc = DocumentFactory.from_file(input_path, format: from_format)

      if options[:verbose]
        say "  Loaded document:", :cyan
        say "    Paragraphs: #{doc.paragraphs.count}"
        say "    Tables: #{doc.tables.count}"
        say "    Styles: #{doc.styles_configuration&.styles&.count || 0}"
      end

      doc.save(output_path, format: to_format)
      say "Conversion complete!", :green if options[:verbose]
    rescue Uniword::Error => e
      handle_error(e)
    rescue StandardError => e
      handle_error(e, verbose: options[:verbose])
    end

    desc "info FILE", "Display document information"
    long_desc <<~DESC
      Display detailed information about a document.

      Examples:
        $ uniword info document.docx
        $ uniword info report.mhtml --verbose
    DESC
    option :verbose, aliases: "-v", desc: "Show detailed information", type: :boolean,
                     default: false
    def info(path)
      say "Analyzing #{path}...", :green

      detector = ::Uniword::FormatDetector.new
      format = detector.detect(path)
      say "\nFormat: #{format.to_s.upcase}", :cyan

      doc = load_document(path)

      say "\nDocument Statistics:", :cyan
      say "  Paragraphs: #{doc.paragraphs.count}"
      say "  Tables: #{doc.tables.count}"
      say "  Text length: #{doc.text.length} characters"
      say "  Styles: #{doc.styles_configuration.styles.count}" if doc.styles_configuration&.styles&.any?

      display_verbose_info(doc) if options[:verbose]
      say "\nAnalysis complete!", :green
    rescue Uniword::Error => e
      handle_error(e)
    rescue StandardError => e
      handle_error(e)
    end

    desc "validate FILE", "Validate document structure"
    long_desc <<~DESC
      Validate a document's structure and check for common issues.

      Examples:
        $ uniword validate document.docx
        $ uniword validate report.mhtml --verbose
    DESC
    option :verbose, aliases: "-v", desc: "Show detailed validation results", type: :boolean,
                     default: false
    def validate(path)
      say "Validating #{path}...", :green

      doc = load_document(path)
      say "File format is valid", :green

      if doc.valid?
        say "Document structure is valid", :green
      else
        say "Document has structural issues", :yellow
      end

      if doc.paragraphs.any? || doc.tables.any?
        say "Document contains content", :green
      else
        say "Document appears to be empty", :yellow
      end

      display_detailed_validation(doc) if options[:verbose]
      say "\nValidation complete!", :green
    rescue Uniword::Error => e
      handle_error(e)
    rescue StandardError => e
      handle_error(e)
    end

    desc "build TEMPLATE OUTPUT", "Build document from a .docx template"
    long_desc <<~DESC
      Build a document by filling a .docx template with data.

      Examples:
        $ uniword build template.docx output.docx --data data.yml
        $ uniword build template.docx output.docx --set title="My Report"
    DESC
    option :data, desc: "Path to YAML or JSON data file", type: :string
    option "set", desc: "Set variable (key=value)", type: :array, default: []
    option :verbose, aliases: "-v", desc: "Verbose output", type: :boolean, default: false
    def build(template_path, output_path)
      unless File.exist?(template_path)
        say("Template not found: #{template_path}", :red)
        exit 1
      end

      template = Uniword::Template::Template.load(template_path)

      if options[:verbose]
        say("Loaded template: #{template_path}", :cyan)
        say("  Markers found: #{template.markers.count}")
      end

      data = load_build_data
      document = template.render(data)
      document.save(output_path)

      say("Built document: #{output_path}", :green)
    rescue Uniword::Error => e
      handle_error(e)
    rescue StandardError => e
      handle_error(e, verbose: options[:verbose])
    end

    desc "check FILE", "Run accessibility and quality checks on a document"
    long_desc <<~DESC
      Run document quality and accessibility checks.

      Examples:
        $ uniword check document.docx
        $ uniword check document.docx --type accessibility
        $ uniword check document.docx --json
    DESC
    option :type, desc: "Check type (quality/accessibility/all)", type: :string,
                  default: "all"
    option :verbose, aliases: "-v", desc: "Show detailed results", type: :boolean,
                     default: false
    option :json, desc: "Output JSON report", type: :boolean, default: false
    def check(path)
      doc = load_document(path)
      check_type = options[:type]

      reports = {}

      if check_type == "all" || check_type == "quality"
        checker = Quality::DocumentChecker.new
        reports[:quality] = checker.check(doc)
      end

      if check_type == "all" || check_type == "accessibility"
        checker = Accessibility::AccessibilityChecker.new
        reports[:accessibility] = checker.check(doc)
      end

      if options[:json]
        require "json"
        output = reports.transform_values do |r|
          { valid: r.valid?, issues: r.respond_to?(:issues) ? r.issues.count : 0 }
        end
        puts JSON.pretty_generate(output)
      else
        display_check_reports(reports)
      end
    rescue Uniword::Error => e
      handle_error(e)
    rescue StandardError => e
      handle_error(e)
    end

    desc "batch PATTERN OUTPUT_DIR", "Batch convert documents matching a glob pattern"
    long_desc <<~DESC
      Convert multiple documents matching a file glob pattern.

      Examples:
        $ uniword batch "docs/*.html" output/
        $ uniword batch "*.mhtml" converted/ --format docx
    DESC
    option :format, aliases: "-f", desc: "Output format (docx/mhtml)", type: :string,
                    default: "docx"
    option :verbose, aliases: "-v", desc: "Verbose output", type: :boolean, default: false
    def batch(pattern, output_dir)
      require "fileutils"
      FileUtils.mkdir_p(output_dir)

      files = Dir.glob(pattern)
      if files.empty?
        say("No files found matching '#{pattern}'", :yellow)
        return
      end

      say("Processing #{files.count} files...", :green) if options[:verbose]

      success = 0
      errors = []

      files.each do |input_path|
        basename = File.basename(input_path, ".*")
        ext = options[:format] == "mhtml" ? ".mhtml" : ".docx"
        output_path = File.join(output_dir, "#{basename}#{ext}")

        begin
          doc = DocumentFactory.from_file(input_path)
          doc.save(output_path, format: options[:format].to_sym)
          say("  #{File.basename(input_path)} -> #{File.basename(output_path)}") if options[:verbose]
          success += 1
        rescue StandardError => e
          errors << "#{File.basename(input_path)}: #{e.message}"
          say("  Error: #{File.basename(input_path)}: #{e.message}", :red) if options[:verbose]
        end
      end

      say("\nBatch complete: #{success} converted, #{errors.count} errors", :green)
      return if errors.empty?

      say("Errors:", :red)
      errors.each { |e| say("  - #{e}", :red) }
    rescue StandardError => e
      say "Error: #{e.message}", :red
      exit 1
    end

    desc "metadata FILE", "Display or edit document metadata"
    long_desc <<~DESC
      Display document metadata. Use --set-title, --set-author, etc. to update.

      Examples:
        $ uniword metadata document.docx
        $ uniword metadata document.docx --set-title "Annual Report"
        $ uniword metadata document.docx --json
    DESC
    option "set-title", type: :string, desc: "Set document title"
    option "set-author", type: :string, desc: "Set document author"
    option "set-subject", type: :string, desc: "Set document subject"
    option "set-keywords", type: :string, desc: "Set document keywords"
    option "set-description", type: :string, desc: "Set document description"
    option :json, desc: "Output as JSON", type: :boolean, default: false
    option :output, aliases: "-o", desc: "Output file (required when setting metadata)",
            type: :string
    def metadata(path)
      doc = load_document(path)
      cp = doc.core_properties

      updated = apply_metadata_updates(cp)

      if updated
        output_path = options[:output]
        unless output_path
          say("Error: --output is required when setting metadata", :red)
          exit 1
        end
        doc.save(output_path)
        say("Metadata updated and saved to #{output_path}", :green)
        return
      end

      display_metadata(cp)
    rescue Uniword::Error => e
      handle_error(e)
    rescue StandardError => e
      handle_error(e)
    end

    desc "verify FILE", "Verify DOCX against OPC and XSD schemas"
    long_desc <<~DESC
      Perform comprehensive DOCX verification across three layers:

      1. OPC Package -- ZIP integrity, content types, relationships
      2. XSD Schema -- XML schema validation (namespace-aware)
      3. Word Document -- semantic checks

      Examples:
        $ uniword verify document.docx
        $ uniword verify document.docx --verbose
        $ uniword verify document.docx --xsd
    DESC
    option :verbose, aliases: "-v", desc: "Show detailed issue listing",
                     type: :boolean, default: false
    option :json, desc: "Output JSON report", type: :boolean, default: false
    option :yaml, desc: "Output YAML report", type: :boolean, default: false
    option :xsd, desc: "Enable XSD schema validation", type: :boolean, default: false
    def verify(path)
      unless File.exist?(path)
        say(Rainbow("  File not found: #{path}").red.bright)
        exit 1
      end

      orchestrator = Uniword::Validation::VerifyOrchestrator.new(
        xsd_validation: options[:xsd]
      )
      report = orchestrator.verify(path)

      if options[:json]
        puts report.to_json
      elsif options[:yaml]
        require "yaml"
        puts YAML.dump(JSON.parse(report.to_json))
      else
        formatter = Uniword::Validation::Report::TerminalFormatter.new
        puts formatter.format(report, verbose: options[:verbose])
      end

      exit report.valid ? 0 : 1
    rescue StandardError => e
      say(Rainbow("  Error: #{e.message}").red.bright)
      exit 1
    end

    desc "version", "Show Uniword version"
    def version
      say "Uniword version #{Uniword::VERSION}", :green
    end

    # Register subcommands
    desc "theme SUBCOMMAND", "Manage document themes"
    subcommand "theme", ThemeCLI

    desc "styleset SUBCOMMAND", "Manage document StyleSets"
    subcommand "styleset", StyleSetCLI

    desc "resources SUBCOMMAND", "Manage Word resources"
    subcommand "resources", ResourcesCLI

    desc "generate INPUT OUTPUT", "Generate DOCX from structured text"
    subcommand "generate", GenerateCLI

    desc "review SUBCOMMAND", "Review comments and tracked changes"
    subcommand "review", ReviewCLI

    desc "diff SUBCOMMAND", "Compare two DOCX files"
    subcommand "diff", DiffCLI

    desc "toc SUBCOMMAND", "Generate and manage table of contents"
    subcommand "toc", TocCLI

    desc "images SUBCOMMAND", "Manage images in documents"
    subcommand "images", ImagesCLI

    desc "spellcheck SUBCOMMAND", "Spell and grammar checking"
    subcommand "spellcheck", SpellcheckCLI

    desc "template SUBCOMMAND", "Manage document templates"
    subcommand "template", TemplateCLI

    desc "headers SUBCOMMAND", "Manage headers and footers"
    subcommand "headers", HeadersCLI

    desc "watermark SUBCOMMAND", "Manage watermarks"
    subcommand "watermark", WatermarkCLI

    desc "protect SUBCOMMAND", "Manage document protection"
    subcommand "protect", ProtectCLI

    private

    def display_verbose_info(doc)
      say "\nDetailed Information:", :cyan

      if doc.paragraphs.any?
        say "  First paragraphs:"
        doc.paragraphs.first(3).each_with_index do |para, i|
          text = para.text[0..80]
          text += "..." if para.text.length > 80
          say "    #{i + 1}. #{text}"
        end
      end

      if doc.tables.any?
        say "  Tables:"
        doc.tables.each_with_index do |table, i|
          say "    #{i + 1}. #{table.row_count} rows x #{table.column_count} columns"
        end
      end
    end

    def display_detailed_validation(doc)
      say "\nDetailed Validation:", :cyan

      empty_paras = doc.paragraphs.count(&:empty?)
      if empty_paras.positive?
        say "  #{empty_paras} empty paragraph(s) found", :yellow
      else
        say "  All paragraphs have content", :green
      end

      if doc.tables.any?
        empty_tables = doc.tables.count(&:empty?)
        if empty_tables.positive?
          say "  #{empty_tables} empty table(s) found", :yellow
        else
          say "  All tables have content", :green
        end
      end
    end

    def display_check_reports(reports)
      reports.each do |type, report|
        label = type.to_s.capitalize
        if report.valid?
          say("#{label}: No issues found", :green)
        else
          issue_count = report.respond_to?(:issues) ? report.issues.count : "?"
          say("#{label}: #{issue_count} issue(s) found", :yellow)
          if options[:verbose] && report.respond_to?(:issues)
            report.issues.each do |issue|
              say("  - #{issue}", :yellow)
            end
          end
        end
      end
    end

    def load_build_data
      data = {}
      if options[:data]
        unless File.exist?(options[:data])
          say("Data file not found: #{options[:data]}", :red)
          exit 1
        end

        ext = File.extname(options[:data])
        content = File.read(options[:data])
        data = if ext == ".json"
                 require "json"
                 JSON.parse(content)
               else
                 require "yaml"
                 YAML.safe_load(content) || {}
               end
      end

      options["set"].each do |pair|
        key, value = pair.split("=", 2)
        data[key] = value if key && value
      end

      data
    end

    def apply_metadata_updates(core_properties)
      setters = {
        "set-title" => :title=,
        "set-author" => :creator=,
        "set-subject" => :subject=,
        "set-keywords" => :keywords=,
        "set-description" => :description=,
      }
      updated = false
      setters.each do |opt, setter|
        next unless options[opt]

        core_properties&.send(setter, options[opt])
        updated = true
      end
      updated
    end

    def display_metadata(core_properties)
      meta = {
        title: core_properties&.title,
        author: core_properties&.creator,
        subject: core_properties&.subject,
        keywords: core_properties&.keywords,
        description: core_properties&.description,
        last_modified_by: core_properties&.last_modified_by,
        revision: core_properties&.revision,
        created: core_properties&.created,
        modified: core_properties&.modified,
      }

      if options[:json]
        require "json"
        puts JSON.pretty_generate(meta)
      else
        say "Document Metadata:", :cyan
        say "  Title:       #{meta[:title] || "(none)"}"
        say "  Author:      #{meta[:author] || "(none)"}"
        say "  Subject:     #{meta[:subject] || "(none)"}"
        say "  Keywords:    #{meta[:keywords] || "(none)"}"
        say "  Description: #{meta[:description] || "(none)"}"
        say "  Modified by: #{meta[:last_modified_by] || "(none)"}"
        say "  Revision:    #{meta[:revision] || "(none)"}"
        say "  Created:     #{meta[:created] || "(unknown)"}"
        say "  Modified:    #{meta[:modified] || "(unknown)"}"
      end
    end
  end
end
