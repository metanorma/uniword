# frozen_string_literal: true

# All Metadata classes autoloaded via lib/uniword/metadata.rb
# DocumentFactory autoloaded via lib/uniword.rb

module Uniword
  module Metadata
    # Main orchestrator for metadata operations.
    #
    # Responsibility: Coordinate all metadata operations.
    # Single Responsibility: Only orchestrates, delegates to specialized classes.
    #
    # The MetadataManager:
    # - Coordinates extraction, validation, updating, and indexing
    # - Provides unified interface for all metadata operations
    # - Delegates to specialized classes for actual work
    # - Follows Open/Closed Principle via external configuration
    #
    # Architecture:
    # - MetadataManager (orchestrator) - this class
    # - MetadataExtractor (extraction logic)
    # - MetadataUpdater (update logic)
    # - MetadataValidator (validation logic)
    # - MetadataIndex (batch operations)
    # - Metadata (value object)
    #
    # @example Basic usage
    #   manager = MetadataManager.new
    #   metadata = manager.extract(document)
    #   puts metadata[:title]
    #
    # @example Update metadata
    #   manager.update(document, {
    #     title: "New Title",
    #     author: "New Author"
    #   })
    #
    # @example Batch operations
    #   index = manager.extract_batch(['doc1.docx', 'doc2.docx'])
    #   index.export_json('metadata_index.json')
    class MetadataManager
      # @return [MetadataExtractor] Extractor instance
      attr_reader :extractor

      # @return [MetadataUpdater] Updater instance
      attr_reader :updater

      # @return [MetadataValidator] Validator instance
      attr_reader :validator

      # Initialize a new MetadataManager.
      #
      # @param config_file [String] Path to schema configuration
      #
      # @example Create manager
      #   manager = MetadataManager.new
      #
      # @example Custom configuration
      #   manager = MetadataManager.new(
      #     config_file: 'config/custom_schema.yml'
      #   )
      def initialize(config_file: 'metadata_schema')
        @extractor = MetadataExtractor.new(config_file: config_file)
        @updater = MetadataUpdater.new
        @validator = MetadataValidator.new(config_file: config_file)
        @config_file = config_file
      end

      # Extract metadata from a document.
      #
      # @param document [Document, String] Document or file path
      # @return [Metadata] Extracted metadata
      #
      # @example Extract from document
      #   metadata = manager.extract(document)
      #   puts metadata[:word_count]
      #
      # @example Extract from file
      #   metadata = manager.extract('document.docx')
      def extract(document)
        doc = load_document(document)
        @extractor.extract(doc)
      end

      # Extract and validate metadata.
      #
      # @param document [Document, String] Document or file path
      # @param scenario [Symbol, nil] Validation scenario
      # @return [Hash] Result with :metadata and :validation keys
      #
      # @example Extract and validate
      #   result = manager.extract_and_validate(document)
      #   if result[:validation][:valid]
      #     puts "Valid metadata"
      #   end
      def extract_and_validate(document, scenario: nil)
        metadata = extract(document)
        validation = @validator.validate(metadata, scenario: scenario)

        {
          metadata: metadata,
          validation: validation
        }
      end

      # Update document metadata.
      #
      # @param document [Document, String] Document or file path
      # @param metadata [Metadata, Hash] Metadata to apply
      # @param validate [Boolean] Validate before updating
      # @param scenario [Symbol, nil] Validation scenario
      # @return [Hash] Result with :success and optional :errors keys
      #
      # @example Update document
      #   manager.update(document, {
      #     title: "New Title",
      #     author: "Jane Doe"
      #   })
      #
      # @example Update with validation
      #   result = manager.update(document, metadata, validate: true)
      #   puts "Success: #{result[:success]}"
      def update(document, metadata, validate: false, scenario: nil)
        doc = load_document(document)
        meta = metadata.is_a?(Metadata) ? metadata : Metadata.new(metadata)

        # Validate if requested
        if validate
          validation = @validator.validate(meta, scenario: scenario)
          unless validation[:valid]
            return {
              success: false,
              errors: validation[:errors]
            }
          end
        end

        # Update document
        @updater.update(doc, meta)

        { success: true }
      end

      # Validate metadata.
      #
      # @param metadata [Metadata, Hash] Metadata to validate
      # @param scenario [Symbol, nil] Validation scenario
      # @return [Hash] Validation result
      #
      # @example Validate metadata
      #   result = manager.validate(metadata)
      #   puts "Valid: #{result[:valid]}"
      def validate(metadata, scenario: nil)
        @validator.validate(metadata, scenario: scenario)
      end

      # Extract metadata from multiple documents.
      #
      # @param paths [Array<String>] Document file paths or glob patterns
      # @return [MetadataIndex] Index with extracted metadata
      #
      # @example Extract from multiple files
      #   index = manager.extract_batch(['doc1.docx', 'doc2.docx'])
      #   puts "Processed #{index.size} documents"
      #
      # @example Extract using glob
      #   index = manager.extract_batch(Dir.glob('*.docx'))
      #   index.export_json('metadata.json')
      def extract_batch(paths)
        index = MetadataIndex.new(config_file: @config_file)

        paths.each do |path|
          # Expand glob patterns
          expanded_paths = if path.include?('*')
                             Dir.glob(path)
                           else
                             [path]
                           end

          expanded_paths.each do |file_path|
            next unless File.exist?(file_path)

            metadata = extract(file_path)
            index.add(file_path, metadata)
          end
        rescue StandardError => e
          warn "Warning: Failed to extract metadata from #{path}: #{e.message}"
        end

        index
      end

      # Extract metadata from documents matching a pattern.
      #
      # @param pattern [String] Glob pattern
      # @return [MetadataIndex] Index with extracted metadata
      #
      # @example Extract from pattern
      #   index = manager.extract_from_pattern('**/*.docx')
      def extract_from_pattern(pattern)
        paths = Dir.glob(pattern)
        extract_batch(paths)
      end

      # Extract metadata from directory.
      #
      # @param directory [String] Directory path
      # @param recursive [Boolean] Search recursively
      # @param pattern [String] File pattern (e.g., '*.docx')
      # @return [MetadataIndex] Index with extracted metadata
      #
      # @example Extract from directory
      #   index = manager.extract_from_directory('documents')
      #
      # @example Recursive extraction
      #   index = manager.extract_from_directory('docs', recursive: true)
      def extract_from_directory(directory, recursive: false, pattern: '*.docx')
        glob_pattern = if recursive
                         File.join(directory, '**', pattern)
                       else
                         File.join(directory, pattern)
                       end

        extract_from_pattern(glob_pattern)
      end

      # Update multiple documents with metadata.
      #
      # @param updates [Hash] Path to metadata mapping
      # @param validate [Boolean] Validate before updating
      # @return [Hash] Results with success/failure counts
      #
      # @example Batch update
      #   updates = {
      #     'doc1.docx' => { author: "John" },
      #     'doc2.docx' => { author: "Jane" }
      #   }
      #   results = manager.update_batch(updates)
      def update_batch(updates, validate: false)
        results = {
          success_count: 0,
          failure_count: 0,
          failures: []
        }

        updates.each do |path, metadata|
          result = update(path, metadata, validate: validate)
          if result[:success]
            results[:success_count] += 1
          else
            results[:failure_count] += 1
            results[:failures] << {
              path: path,
              errors: result[:errors]
            }
          end
        rescue StandardError => e
          results[:failure_count] += 1
          results[:failures] << {
            path: path,
            errors: [e.message]
          }
        end

        results
      end

      # Get metadata summary statistics.
      #
      # @param index [MetadataIndex] Metadata index
      # @return [Hash] Summary statistics
      #
      # @example Get summary
      #   index = manager.extract_batch(files)
      #   summary = manager.summary(index)
      def summary(index)
        return {} if index.empty?

        all_metadata = index.all

        {
          document_count: index.size,
          total_words: all_metadata.sum { |m| m[:word_count] || 0 },
          total_pages: all_metadata.sum { |m| m[:page_count] || 0 },
          total_images: all_metadata.sum { |m| m[:image_count] || 0 },
          total_tables: all_metadata.sum { |m| m[:table_count] || 0 },
          authors: all_metadata.map { |m| m[:author] }.compact.uniq,
          categories: all_metadata.map { |m| m[:category] }.compact.uniq
        }
      end

      # Query documents by metadata criteria.
      #
      # @param index [MetadataIndex] Metadata index
      # @param criteria [Hash] Query criteria
      # @return [Hash] Matching documents
      #
      # @example Query by author
      #   results = manager.query(index, author: "John Doe")
      #
      # @example Query by multiple criteria
      #   results = manager.query(index, {
      #     category: "Report",
      #     status: "final"
      #   })
      def query(index, criteria)
        index.entries.select do |_path, metadata|
          criteria.all? do |key, value|
            metadata[key] == value
          end
        end
      end

      private

      # Load document from path or return document.
      #
      # @param document [Document, String] Document or file path
      # @return [Document] Loaded document
      def load_document(document)
        case document
        when String
          # Load from file
          DocumentFactory.from_file(document)
        when Document
          document
        else
          raise ArgumentError,
                "Expected Document or file path, got #{document.class}"
        end
      end
    end
  end
end
