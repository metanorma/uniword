# frozen_string_literal: true

require "fileutils"
require "json"
require "time"
require "yaml"

module Uniword
  # High-level template library management.
  #
  # Manages a directory of .docx template files with sidecar metadata
  # (.uniword.json). Provides create, list, and apply operations used by
  # the CLI and directly by Ruby code.
  #
  # @example Create a template from an existing DOCX
  #   Uniword::TemplateManager.create("report", "report.docx", "templates")
  #
  # @example List templates
  #   templates = Uniword::TemplateManager.list("templates")
  #   templates.each { |t| puts t[:name] }
  #
  # @example Apply a template
  #   Uniword::TemplateManager.apply("report", { title: "Q1" }, "output.docx", template_dir: "templates")
  module TemplateManager
    METADATA_EXT = ".uniword.json"

    # Create a template from an existing DOCX file.
    #
    # Copies the source DOCX into the template library directory and writes
    # sidecar metadata with name, description, source path, and timestamps.
    #
    # @param name [String] Template name (used as filename stem)
    # @param source_docx [String] Path to the source .docx file
    # @param output_dir [String] Template library directory
    # @param description [String, nil] Optional description of the template
    # @return [Hash] Metadata hash for the created template
    # @raise [ArgumentError] If source file does not exist
    def self.create(name, source_docx, output_dir, description: nil)
      raise ArgumentError, "Source file not found: #{source_docx}" unless File.exist?(source_docx)

      FileUtils.mkdir_p(output_dir)

      dest_path = File.join(output_dir, "#{name}.docx")
      FileUtils.cp(source_docx, dest_path)

      metadata = build_metadata(
        name: name,
        description: description,
        source: File.basename(source_docx)
      )

      write_metadata(output_dir, name, metadata)
      metadata
    end

    # List available templates in a directory.
    #
    # Scans the directory for .docx files, reads their sidecar metadata
    # (if present), and returns an array of template info hashes sorted
    # alphabetically by name.
    #
    # @param template_dir [String] Template library directory
    # @return [Array<Hash>] Array of template info hashes, each containing
    #   :name, :path, :description, :source, :created_at, :updated_at, :markers
    def self.list(template_dir)
      return [] unless Dir.exist?(template_dir)

      docx_files = Dir.glob(File.join(template_dir, "*.docx")).sort

      docx_files.map do |path|
        name = File.basename(path, ".docx")
        metadata = read_metadata(template_dir, name)

        {
          name: name,
          path: path,
          description: metadata[:description],
          source: metadata[:source],
          created_at: metadata[:created_at],
          updated_at: metadata[:updated_at],
          markers: metadata[:markers]
        }
      end
    end

    # Apply a template with data to generate a new document.
    #
    # Loads the named template from the library, renders it with the provided
    # data using Uniword::Template, and saves the result to output_path.
    #
    # @param template_name [String] Name of the template in the library
    # @param data [Hash] Data to fill template markers
    # @param output_path [String] Where to save the rendered document
    # @param template_dir [String] Template library directory
    # @return [void]
    # @raise [ArgumentError] If the template is not found in the library
    def self.apply(template_name, data, output_path, template_dir:)
      template_path = File.join(template_dir, "#{template_name}.docx")

      unless File.exist?(template_path)
        raise ArgumentError,
              "Template '#{template_name}' not found in #{template_dir}"
      end

      template = Uniword::Template::Template.load(template_path)
      document = template.render(data)
      document.save(output_path)
    end

    class << self
      private

      def build_metadata(name:, description:, source:)
        now = Time.now.utc.iso8601
        {
          name: name,
          description: description,
          source: source,
          created_at: now,
          updated_at: now,
          markers: count_markers(source)
        }
      end

      def count_markers(source_path)
        return 0 unless File.exist?(source_path)

        doc = Uniword::DocumentFactory.from_file(source_path)
        template = Uniword::Template::Template.new(doc)
        template.markers.count
      rescue StandardError
        0
      end

      def write_metadata(output_dir, name, metadata)
        meta_path = File.join(output_dir, "#{name}#{METADATA_EXT}")
        File.write(meta_path, JSON.pretty_generate(metadata))
      end

      def read_metadata(template_dir, name)
        meta_path = File.join(template_dir, "#{name}#{METADATA_EXT}")
        return {} unless File.exist?(meta_path)

        content = File.read(meta_path)
        parsed = JSON.parse(content)
        symbolize_keys(parsed)
      rescue JSON::ParserError
        {}
      end

      def symbolize_keys(hash)
        hash.each_with_object({}) do |(key, value), result|
          sym_key = key.to_sym
          result[sym_key] = value.is_a?(Hash) ? symbolize_keys(value) : value
        end
      end
    end
  end
end
