# frozen_string_literal: true

module Uniword
  module Assembly
    # Legacy TOC generator - thin wrapper around Toc model.
    #
    # DEPRECATED: Use Toc model directly instead.
    # This class exists for backward compatibility.
    #
    # @example Use Toc model directly (recommended)
    #   toc = Toc.new(max_level: 3)
    #   paragraphs = toc.generate_from_document(document)
    #
    # @example Legacy usage (deprecated)
    #   gen = TocGenerator.new
    #   toc = gen.generate(document)
    class TocGenerator
      # @return [Integer] Maximum heading level to include
      attr_reader :max_level

      # @return [String] TOC title
      attr_reader :title

      # Initialize TOC generator.
      #
      # @param max_level [Integer] Maximum heading level (1-9)
      # @param title [String] TOC title
      # @param include_page_numbers [Boolean] Include page numbers
      #
      # @example Create generator
      #   gen = TocGenerator.new
      #
      # @example Custom configuration
      #   gen = TocGenerator.new(
      #     max_level: 3,
      #     title: "Contents"
      #   )
      def initialize(max_level: 9, title: 'Table of Contents',
                     include_page_numbers: true)
        @max_level = max_level
        @title = title
        @include_page_numbers = include_page_numbers
      end

      # Generate TOC from document.
      #
      # @param document [Document] Source document
      # @return [Array<Paragraph>] TOC paragraphs
      #
      # @example Generate TOC
      #   toc_paragraphs = gen.generate(document)
      def generate(document)
        toc_model.generate_from_document(document)
      end

      # Generate TOC as new document.
      #
      # @param document [Wordprocessingml::DocumentRoot] Source document
      # @return [Wordprocessingml::DocumentRoot] New document with TOC
      #
      # @example Generate TOC document
      #   toc_doc = gen.generate_document(document)
      def generate_document(document)
        toc_model.generate_document(document)
      end

      # Insert TOC into document at position.
      #
      # @param document [Document] Target document
      # @param position [Integer] Insertion position
      # @return [void]
      #
      # @example Insert TOC at beginning
      #   gen.insert_toc(document, 0)
      def insert_toc(document, position = 0)
        toc_model.insert_into(document, position)
      end

      private

      # Create the Toc model with current configuration.
      #
      # @return [Toc] The Toc model
      def toc_model
        @toc_model ||= Toc.new(
          title: @title,
          max_level: @max_level,
          include_page_numbers: @include_page_numbers,
          create_hyperlinks: false # Legacy behavior
        )
      end
    end
  end
end
