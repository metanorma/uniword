# frozen_string_literal: true

require 'json'
require 'yaml'
require 'csv'
require_relative 'metadata'
require_relative '../configuration/configuration_loader'

module Uniword
  module Metadata
    # Manages batch metadata operations and indexing.
    #
    # Responsibility: Handle batch metadata extraction and export.
    # Single Responsibility: Only handles batch operations and indexing.
    #
    # The MetadataIndex:
    # - Stores metadata for multiple documents
    # - Provides query/filter operations
    # - Exports to JSON, YAML, CSV, XML formats
    # - Maintains document-to-metadata mappings
    #
    # Does NOT handle: Single document extraction or validation.
    # Those responsibilities belong to separate classes.
    #
    # @example Create index
    #   index = MetadataIndex.new
    #   index.add('doc1.docx', metadata1)
    #   index.add('doc2.docx', metadata2)
    #
    # @example Export index
    #   index.export_json('index.json')
    #   index.export_csv('index.csv')
    class MetadataIndex
      # @return [Hash] Document path to metadata mapping
      attr_reader :entries

      # @return [Hash] Export configuration
      attr_reader :export_config

      # Initialize a new MetadataIndex.
      #
      # @param config_file [String] Path to schema configuration
      #
      # @example Create index
      #   index = MetadataIndex.new
      #
      # @example Custom config
      #   index = MetadataIndex.new(
      #     config_file: 'config/custom_schema.yml'
      #   )
      def initialize(config_file: 'metadata_schema')
        @entries = {}
        @export_config = load_export_config(config_file)
      end

      # Add metadata entry to index.
      #
      # @param path [String] Document file path
      # @param metadata [Metadata, Hash] Document metadata
      # @return [void]
      #
      # @example Add entry
      #   index.add('document.docx', metadata)
      def add(path, metadata)
        meta = metadata.is_a?(Metadata) ? metadata : Metadata.new(metadata)
        @entries[path] = meta
      end

      # Get metadata for a document.
      #
      # @param path [String] Document file path
      # @return [Metadata, nil] Document metadata or nil
      #
      # @example Get entry
      #   metadata = index.get('document.docx')
      def get(path)
        @entries[path]
      end

      # Check if index contains a document.
      #
      # @param path [String] Document file path
      # @return [Boolean] true if document exists in index
      #
      # @example Check existence
      #   index.has?('document.docx') # => true
      def has?(path)
        @entries.key?(path)
      end

      # Remove document from index.
      #
      # @param path [String] Document file path
      # @return [Metadata, nil] Removed metadata or nil
      #
      # @example Remove entry
      #   metadata = index.remove('document.docx')
      def remove(path)
        @entries.delete(path)
      end

      # Get count of indexed documents.
      #
      # @return [Integer] Number of documents
      #
      # @example Get count
      #   count = index.size
      def size
        @entries.size
      end

      # Check if index is empty.
      #
      # @return [Boolean] true if no documents
      #
      # @example Check if empty
      #   index.empty? # => false
      def empty?
        @entries.empty?
      end

      # Get all document paths.
      #
      # @return [Array<String>] All document paths
      #
      # @example Get paths
      #   paths = index.paths
      def paths
        @entries.keys
      end

      # Get all metadata entries.
      #
      # @return [Array<Metadata>] All metadata objects
      #
      # @example Get all metadata
      #   all_metadata = index.all
      def all
        @entries.values
      end

      # Filter entries by condition.
      #
      # @yield [path, metadata] Block to test each entry
      # @return [Hash] Filtered entries
      #
      # @example Filter by author
      #   by_author = index.filter { |path, meta| meta[:author] == "John" }
      def filter(&block)
        @entries.select(&block)
      end

      # Find first entry matching condition.
      #
      # @yield [path, metadata] Block to test each entry
      # @return [Array, nil] [path, metadata] or nil
      #
      # @example Find by title
      #   entry = index.find { |path, meta| meta[:title] =~ /Report/ }
      def find(&block)
        @entries.find(&block)
      end

      # Query entries by metadata field.
      #
      # @param field [Symbol] Metadata field name
      # @param value [Object] Field value to match
      # @return [Hash] Matching entries
      #
      # @example Query by category
      #   reports = index.query(:category, "Report")
      def query(field, value)
        @entries.select { |_path, meta| meta[field] == value }
      end

      # Export index to JSON file.
      #
      # @param output_path [String] Output file path
      # @param pretty [Boolean] Pretty print JSON
      # @return [void]
      #
      # @example Export to JSON
      #   index.export_json('metadata.json')
      #   index.export_json('metadata.json', pretty: true)
      def export_json(output_path, pretty: nil)
        config = @export_config[:json] || {}
        pretty = config.fetch(:pretty_print, true) if pretty.nil?
        include_null = config.fetch(:include_null_values, false)

        data = build_export_data(include_null: include_null)

        File.write(output_path, pretty ? JSON.pretty_generate(data) : JSON.generate(data))
      end

      # Export index to YAML file.
      #
      # @param output_path [String] Output file path
      # @return [void]
      #
      # @example Export to YAML
      #   index.export_yaml('metadata.yml')
      def export_yaml(output_path)
        config = @export_config[:yaml] || {}
        include_null = config.fetch(:include_null_values, false)

        data = build_export_data(include_null: include_null)

        File.write(output_path, YAML.dump(data))
      end

      # Export index to CSV file.
      #
      # @param output_path [String] Output file path
      # @param columns [Array<Symbol>, nil] Columns to export (nil = all)
      # @return [void]
      #
      # @example Export to CSV
      #   index.export_csv('metadata.csv')
      #   index.export_csv('metadata.csv', columns: [:title, :author])
      def export_csv(output_path, columns: nil)
        config = @export_config[:csv] || {}
        delimiter = config.fetch(:delimiter, ',')
        quote_char = config.fetch(:quote_char, '"')
        include_headers = config.fetch(:include_headers, true)
        columns ||= config[:columns]&.map(&:to_sym)

        # Determine columns from first entry if not specified
        if columns.nil? && !@entries.empty?
          first_meta = @entries.values.first
          columns = first_meta.keys
        end

        CSV.open(output_path, 'w', col_sep: delimiter, quote_char: quote_char) do |csv|
          # Write headers
          csv << (['path'] + columns.map(&:to_s)) if include_headers

          # Write data rows
          @entries.each do |path, metadata|
            row = [path] + columns.map { |col| format_csv_value(metadata[col]) }
            csv << row
          end
        end
      end

      # Export index to XML file.
      #
      # @param output_path [String] Output file path
      # @return [void]
      #
      # @example Export to XML
      #   index.export_xml('metadata.xml')
      def export_xml(output_path)
        config = @export_config[:xml] || {}
        root_element = config.fetch(:root_element, 'metadata')
        include_null = config.fetch(:include_null_values, false)

        xml = build_xml(root_element: root_element, include_null: include_null)

        File.write(output_path, xml)
      end

      # Convert index to hash.
      #
      # @param include_null [Boolean] Include nil values
      # @return [Hash] Hash representation
      #
      # @example Convert to hash
      #   hash = index.to_h
      def to_h(include_null: true)
        @entries.transform_values do |metadata|
          metadata.to_h(include_nil: include_null)
        end
      end

      # Convert index to array of entries.
      #
      # @return [Array<Hash>] Array of entry hashes
      #
      # @example Convert to array
      #   array = index.to_a
      def to_a
        @entries.map do |path, metadata|
          metadata.to_h.merge(path: path)
        end
      end

      # Merge with another index.
      #
      # @param other [MetadataIndex] Other index to merge
      # @return [MetadataIndex] New merged index
      #
      # @example Merge indexes
      #   merged = index1.merge(index2)
      def merge(other)
        new_index = self.class.new
        new_index.instance_variable_set(:@entries, @entries.dup)
        new_index.instance_variable_set(:@export_config, @export_config)

        other.entries.each do |path, metadata|
          new_index.add(path, metadata)
        end

        new_index
      end

      # String representation.
      #
      # @return [String] String representation
      def to_s
        "#<MetadataIndex #{@entries.size} documents>"
      end

      # Detailed inspection.
      #
      # @return [String] Detailed representation
      def inspect
        "#<Uniword::Metadata::MetadataIndex entries=#{@entries.size}>"
      end

      private

      # Load export configuration.
      #
      # @param config_file [String] Configuration file name or path
      # @return [Hash] Export configuration
      def load_export_config(config_file)
        config = if File.exist?(config_file)
                   Configuration::ConfigurationLoader.load_file(config_file)
                 else
                   Configuration::ConfigurationLoader.load(config_file)
                 end

        config[:export_formats] || default_export_config
      rescue Configuration::ConfigurationError
        default_export_config
      end

      # Get default export configuration.
      #
      # @return [Hash] Default export config
      def default_export_config
        {
          json: { enabled: true, pretty_print: true },
          yaml: { enabled: true },
          csv: { enabled: true, delimiter: ',' },
          xml: { enabled: true, root_element: 'metadata' }
        }
      end

      # Build export data structure.
      #
      # @param include_null [Boolean] Include nil values
      # @return [Hash] Export data
      def build_export_data(include_null: false)
        {
          metadata_index: {
            generated_at: Time.now.iso8601,
            document_count: @entries.size,
            documents: @entries.map do |path, metadata|
              {
                path: path,
                metadata: metadata.to_h(include_nil: include_null)
              }
            end
          }
        }
      end

      # Format value for CSV export.
      #
      # @param value [Object] Value to format
      # @return [String] Formatted value
      def format_csv_value(value)
        case value
        when Array
          value.join('; ')
        when Hash
          value.to_json
        when Time, DateTime
          value.iso8601
        when Date
          value.to_s
        when nil
          ''
        else
          value.to_s
        end
      end

      # Build XML representation.
      #
      # @param root_element [String] Root element name
      # @param include_null [Boolean] Include nil values
      # @return [String] XML string
      def build_xml(root_element: 'metadata', include_null: false)
        xml = ['<?xml version="1.0" encoding="UTF-8"?>']
        xml << "<#{root_element}_index>"
        xml << "  <generated_at>#{Time.now.iso8601}</generated_at>"
        xml << "  <document_count>#{@entries.size}</document_count>"
        xml << '  <documents>'

        @entries.each do |path, metadata|
          xml << '    <document>'
          xml << "      <path>#{escape_xml(path)}</path>"
          xml << '      <metadata>'

          metadata.to_h(include_nil: include_null).each do |key, value|
            next if value.nil? && !include_null

            xml << "        <#{key}>#{escape_xml(format_xml_value(value))}</#{key}>"
          end

          xml << '      </metadata>'
          xml << '    </document>'
        end

        xml << '  </documents>'
        xml << "</#{root_element}_index>"
        xml.join("\n")
      end

      # Format value for XML export.
      #
      # @param value [Object] Value to format
      # @return [String] Formatted value
      def format_xml_value(value)
        case value
        when Array
          value.to_json
        when Hash
          value.to_json
        when Time, DateTime
          value.iso8601
        when Date
          value.to_s
        else
          value.to_s
        end
      end

      # Escape XML special characters.
      #
      # @param text [String] Text to escape
      # @return [String] Escaped text
      def escape_xml(text)
        text.to_s
            .gsub('&', '&amp;')
            .gsub('<', '&lt;')
            .gsub('>', '&gt;')
            .gsub('"', '&quot;')
            .gsub("'", '&apos;')
      end
    end
  end
end
