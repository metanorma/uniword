# frozen_string_literal: true

# All classes autoloaded via lib/uniword/metadata.rb and lib/uniword/configuration.rb


module Uniword
  module Metadata
    # Extracts metadata from documents.
    #
    # Responsibility: Extract metadata from document structure.
    # Single Responsibility: Only handles metadata extraction.
    #
    # The MetadataExtractor:
    # - Extracts core properties (title, author, etc.)
    # - Extracts extended properties (company, category, etc.)
    # - Computes statistical metadata (word count, page count, etc.)
    # - Extracts content metadata (headings, first paragraph, etc.)
    #
    # Does NOT handle: Validation, updating, or indexing.
    # Those responsibilities belong to separate classes.
    #
    # @example Extract metadata
    #   extractor = MetadataExtractor.new
    #   metadata = extractor.extract(document)
    #   puts metadata[:word_count]
    #
    # @example Custom config
    #   extractor = MetadataExtractor.new(
    #     config_file: 'custom_metadata_schema'
    #   )
    class MetadataExtractor
      # @return [Hash] Loaded configuration
      attr_reader :config

      # Initialize a new MetadataExtractor.
      #
      # @param config_file [String] Path to schema configuration
      #
      # @example Create extractor
      #   extractor = MetadataExtractor.new
      #
      # @example Custom config
      #   extractor = MetadataExtractor.new(
      #     config_file: 'config/custom_schema.yml'
      #   )
      def initialize(config_file: 'metadata_schema')
        @config = load_configuration(config_file)
      end

      # Extract metadata from a document.
      #
      # @param document [Document] The document to extract from
      # @return [Metadata] Extracted metadata
      # @raise [ArgumentError] if document is not valid
      #
      # @example Extract metadata
      #   metadata = extractor.extract(document)
      #   puts metadata[:title]
      #   puts metadata[:word_count]
      def extract(document)
        validate_document(document)

        metadata = Metadata.new

        # Extract different metadata categories
        extract_core_properties(document, metadata)
        extract_extended_properties(document, metadata)
        extract_statistical_metadata(document, metadata) if extraction_enabled?(:statistics)
        extract_content_metadata(document, metadata) if extraction_enabled?(:content)

        metadata
      end

      private

      # Load configuration from file.
      #
      # @param config_file [String] Configuration file name or path
      # @return [Hash] Loaded configuration
      def load_configuration(config_file)
        if File.exist?(config_file)
          Configuration::ConfigurationLoader.load_file(config_file)
        else
          Configuration::ConfigurationLoader.load(config_file)
        end
      rescue Configuration::ConfigurationError => e
        warn "Warning: #{e.message}. Using default configuration."
        default_configuration
      end

      # Get default configuration.
      #
      # @return [Hash] Default configuration
      def default_configuration
        {
          extraction_config: {
            statistics: { enabled: true },
            content: { enabled: true }
          }
        }
      end

      # Validate document.
      #
      # @param document [Object] The document to validate
      # @raise [ArgumentError] if document is invalid
      def validate_document(document)
        return if document.respond_to?(:paragraphs)

        raise ArgumentError,
              "Document must respond to :paragraphs, got #{document.class}"
      end

      # Check if extraction is enabled for a category.
      #
      # @param category [Symbol] Category name (:statistics, :content)
      # @return [Boolean] true if enabled
      def extraction_enabled?(category)
        extraction_config = @config[:extraction_config]
        return true unless extraction_config

        category_config = extraction_config[category]
        return true unless category_config

        category_config.fetch(:enabled, true)
      end

      # Extract core properties from document.
      #
      # Core properties include: title, author, subject, keywords, etc.
      #
      # @param document [Document] The document
      # @param metadata [Metadata] Metadata to populate
      def extract_core_properties(document, metadata)
        # Extract from document if it has core properties
        if document.respond_to?(:core_properties)
          props = document.core_properties
          return unless props

          metadata[:title] = props[:title] if props[:title]
          metadata[:author] = props[:author] if props[:author]
          metadata[:subject] = props[:subject] if props[:subject]
          metadata[:keywords] = props[:keywords] if props[:keywords]
          metadata[:description] = props[:description] if props[:description]
          metadata[:creator] = props[:creator] if props[:creator]
          metadata[:created_at] = props[:created_at] if props[:created_at]
          metadata[:modified_at] = props[:modified_at] if props[:modified_at]
          metadata[:last_modified_by] = props[:last_modified_by] if props[:last_modified_by]
        end

        # If title not found, try to extract from first heading
        metadata[:title] ||= extract_title_from_content(document)
      end

      # Extract extended properties from document.
      #
      # Extended properties include: company, category, manager, etc.
      #
      # @param document [Document] The document
      # @param metadata [Metadata] Metadata to populate
      def extract_extended_properties(document, metadata)
        return unless document.respond_to?(:extended_properties)

        props = document.extended_properties
        return unless props

        metadata[:company] = props[:company] if props[:company]
        metadata[:category] = props[:category] if props[:category]
        metadata[:manager] = props[:manager] if props[:manager]
        metadata[:language] = props[:language] if props[:language]
        metadata[:version] = props[:version] if props[:version]
        metadata[:revision] = props[:revision] if props[:revision]
        metadata[:status] = props[:status] if props[:status]
      end

      # Extract statistical metadata from document.
      #
      # Statistical metadata includes: word count, page count, etc.
      #
      # @param document [Document] The document
      # @param metadata [Metadata] Metadata to populate
      def extract_statistical_metadata(document, metadata)
        stats_config = @config.dig(:extraction_config, :statistics) || {}

        # Word count
        metadata[:word_count] = compute_word_count(document) if stats_config.fetch(
          :compute_word_count, true
        )

        # Character count
        metadata[:character_count] = compute_character_count(document) if stats_config.fetch(
          :compute_character_count, true
        )

        # Paragraph count
        metadata[:paragraph_count] = document.paragraphs.size

        # Page count estimate
        if stats_config.fetch(:compute_page_estimate, true)
          words_per_page = stats_config.fetch(:page_estimate_words_per_page, 500)
          metadata[:page_count] = estimate_page_count(
            metadata[:word_count] || 0,
            words_per_page
          )
        end

        # Table count
        metadata[:table_count] = document.tables.size if document.respond_to?(:tables)

        # Image count
        metadata[:image_count] = document.images.size if document.respond_to?(:images)

        # Hyperlink count
        metadata[:hyperlink_count] = document.hyperlinks.size if document.respond_to?(:hyperlinks)

        # Footnote count
        if document.respond_to?(:footnotes)
          footnotes = document.footnotes
          metadata[:footnote_count] = case footnotes
                                      when Array
                                        footnotes.size
                                      when Hash
                                        footnotes.size
                                      else
                                        0
                                      end
        end

        # Endnote count
        return unless document.respond_to?(:endnotes)

        endnotes = document.endnotes
        metadata[:endnote_count] = case endnotes
                                   when Array
                                     endnotes.size
                                   when Hash
                                     endnotes.size
                                   else
                                     0
                                   end
      end

      # Extract content metadata from document.
      #
      # Content metadata includes: headings, first paragraph, etc.
      #
      # @param document [Document] The document
      # @param metadata [Metadata] Metadata to populate
      def extract_content_metadata(document, metadata)
        content_config = @config.dig(:extraction_config, :content) || {}

        # Extract headings
        if content_config.fetch(:extract_headings, true)
          metadata[:headings] = extract_headings(
            document,
            max_levels: content_config.fetch(:max_heading_levels, 6)
          )
        end

        # Extract first paragraph
        return unless content_config.fetch(:extract_first_paragraph, true)

        metadata[:first_paragraph] = extract_first_paragraph(
          document,
          max_length: content_config.fetch(:first_paragraph_max_length, 500)
        )
      end

      # Extract title from document content.
      #
      # Looks for first heading or first paragraph.
      #
      # @param document [Document] The document
      # @return [String, nil] Extracted title
      def extract_title_from_content(document)
        return nil if document.paragraphs.empty?

        # Look for first heading-styled paragraph
        first_heading = document.paragraphs.find do |para|
          next false unless para.respond_to?(:style)

          style = para.style
          style && (style.include?('Heading') || style.include?('heading'))
        end

        if first_heading
          first_heading.respond_to?(:text) ? first_heading.text : nil
        else
          # Use first paragraph if no heading found
          first_para = document.paragraphs.first
          text = first_para.respond_to?(:text) ? first_para.text : nil
          text && text.length <= 100 ? text : nil
        end
      end

      # Compute word count for document.
      #
      # @param document [Document] The document
      # @return [Integer] Word count
      def compute_word_count(document)
        text = document.respond_to?(:text) ? document.text : ''
        return 0 if text.nil? || text.empty?

        # Split by whitespace and count non-empty words
        text.split(/\s+/).reject(&:empty?).size
      end

      # Compute character count for document.
      #
      # @param document [Document] The document
      # @return [Integer] Character count
      def compute_character_count(document)
        text = document.respond_to?(:text) ? document.text : ''
        return 0 if text.nil?

        text.length
      end

      # Estimate page count from word count.
      #
      # @param word_count [Integer] Total word count
      # @param words_per_page [Integer] Estimated words per page
      # @return [Integer] Estimated page count
      def estimate_page_count(word_count, words_per_page)
        return 0 if word_count.zero?

        (word_count.to_f / words_per_page).ceil.to_i
      end

      # Extract headings from document.
      #
      # @param document [Document] The document
      # @param max_levels [Integer] Maximum heading levels to extract
      # @return [Array<Hash>] Array of heading data
      def extract_headings(document, max_levels: 6)
        headings = []

        document.paragraphs.each_with_index do |para, index|
          next unless para.respond_to?(:style)

          style = para.style
          next unless style

          # Check if it's a heading style
          level = extract_heading_level(style)
          next unless level && level <= max_levels

          text = para.respond_to?(:text) ? para.text : ''
          next if text.empty?

          headings << {
            level: level,
            text: text,
            position: index
          }
        end

        headings
      end

      # Extract heading level from style name.
      #
      # @param style [String] Style name
      # @return [Integer, nil] Heading level (1-9) or nil
      def extract_heading_level(style)
        return nil unless style

        # Match "Heading 1", "Heading1", "heading 1", etc.
        match = style.match(/heading\s*(\d)/i)
        return nil unless match

        match[1].to_i
      end

      # Extract first paragraph text.
      #
      # @param document [Document] The document
      # @param max_length [Integer] Maximum text length
      # @return [String, nil] First paragraph text
      def extract_first_paragraph(document, max_length: 500)
        return nil if document.paragraphs.empty?

        # Find first non-empty paragraph that's not a heading
        first_para = document.paragraphs.find do |para|
          next false unless para.respond_to?(:text)

          text = para.text
          next false if text.nil? || text.strip.empty?

          # Skip if it's a heading
          if para.respond_to?(:style)
            style = para.style
            next false if style && (style.include?('Heading') || style.include?('heading'))
          end

          true
        end

        return nil unless first_para

        text = first_para.text.strip
        text.length > max_length ? "#{text[0...max_length]}..." : text
      end
    end
  end
end
