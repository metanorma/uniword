# frozen_string_literal: true

module Uniword
  module HeadersFooters
    # Manages headers and footers for a document.
    #
    # Provides CRUD operations for headers and footers with support
    # for default, first-page, and even-page types.
    #
    # @example Add a header with text
    #   manager = Manager.new(doc)
    #   manager.add_header("Confidential", type: "default")
    #
    # @example Add page numbers to footer
    #   manager.add_footer("Page {PAGE}", type: "default")
    class Manager
      TYPES = %w[default first even].freeze

      attr_reader :document

      def initialize(document)
        @document = document
      end

      # List all headers in the document.
      #
      # @return [Array<Hash>] Each hash has :type, :text, :empty keys
      def list_headers
        headers = document.headers || []
        headers.map do |h|
          {
            type: h.type,
            text: extract_text(h),
            empty: h.empty?
          }
        end
      end

      # List all footers in the document.
      #
      # @return [Array<Hash>] Each hash has :type, :text, :empty keys
      def list_footers
        footers = document.footers || []
        footers.map do |f|
          {
            type: f.type,
            text: extract_text(f),
            empty: f.empty?
          }
        end
      end

      # Add a header to the document.
      #
      # @param text [String] Header text content
      # @param type [String] Header type (default/first/even)
      # @return [Uniword::Header] The added header
      # @raise [ArgumentError] If type is invalid
      def add_header(text, type: "default")
        validate_type(type)

        header = Uniword::Header.new(type: type)
        add_text_to(header, text)

        document.headers ||= []
        document.headers << header
        header
      end

      # Add a footer to the document.
      #
      # @param text [String] Footer text content
      # @param type [String] Footer type (default/first/even)
      # @return [Uniword::Footer] The added footer
      # @raise [ArgumentError] If type is invalid
      def add_footer(text, type: "default")
        validate_type(type)

        footer = Uniword::Footer.new(type: type)
        add_text_to(footer, text)

        document.footers ||= []
        document.footers << footer
        footer
      end

      # Remove headers by type.
      #
      # @param type [String] Header type to remove (default/first/even)
      # @return [Integer] Number of headers removed
      def remove_headers(type:)
        return 0 unless document.headers

        before = document.headers.size
        document.headers = document.headers.reject { |h| h.type == type }
        before - document.headers.size
      end

      # Remove footers by type.
      #
      # @param type [String] Footer type to remove (default/first/even)
      # @return [Integer] Number of footers removed
      def remove_footers(type:)
        return 0 unless document.footers

        before = document.footers.size
        document.footers = document.footers.reject { |f| f.type == type }
        before - document.footers.size
      end

      # Clear all headers and footers.
      #
      # @return [void]
      def clear_all
        document.headers = []
        document.footers = []
      end

      private

      def validate_type(type)
        return if TYPES.include?(type)

        raise ArgumentError,
              "Invalid type: #{type}. Must be one of: #{TYPES.join(", ")}"
      end

      def extract_text(container)
        container.paragraphs.map { |p| p.text.to_s }.join(" ")
      end

      def add_text_to(container, text)
        para = Uniword::Wordprocessingml::Paragraph.new
        run = Uniword::Wordprocessingml::Run.new(text: text)
        para.runs << run
        container.paragraphs << para
      end
    end
  end
end
