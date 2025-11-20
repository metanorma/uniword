# frozen_string_literal: true

require_relative 'base_handler'
require_relative '../infrastructure/mime_parser'
require_relative '../infrastructure/mime_packager'
require_relative '../serialization/html_deserializer'
require_relative '../serialization/html_serializer'

module Uniword
  module Formats
    # Handles MHTML (MIME HTML) format files.
    #
    # Responsibility: Coordinate MHTML file operations by delegating to
    # infrastructure and serialization classes. Follows Single Responsibility
    # Principle - the handler orchestrates but doesn't implement details.
    #
    # MHTML files are MIME multipart documents containing HTML and embedded
    # resources. This handler uses:
    # - MimeParser for reading MIME content
    # - MimePackager for creating MIME files
    # - HtmlDeserializer for converting HTML to Document
    # - HtmlSerializer for converting Document to HTML
    #
    # @example Read an MHTML file
    #   handler = Uniword::Formats::MhtmlHandler.new
    #   document = handler.read("document.mhtml")
    #
    # @example Write an MHTML file
    #   handler = Uniword::Formats::MhtmlHandler.new
    #   handler.write(document, "output.mhtml")
    class MhtmlHandler < BaseHandler
      # Get supported file extensions.
      #
      # @return [Array<String>] Array of supported extensions
      def supported_extensions
        ['.mhtml', '.mht']
      end

      protected

      # Extract content from an MHTML file.
      #
      # Delegates to MimeParser to extract the MIME multipart content.
      #
      # @param path [String] The file path
      # @return [Hash] Hash containing HTML and resources
      def extract_content(path)
        mime_parser.parse(path)
      end

      # Deserialize HTML content into a Document.
      #
      # Delegates to HtmlDeserializer to parse HTML and build document model.
      #
      # @param mime_parts [Hash] The extracted MIME parts
      # @return [Document] The deserialized document
      def deserialize(mime_parts)
        html_deserializer.deserialize(mime_parts)
      end

      # Serialize a Document into HTML format.
      #
      # Delegates to HtmlSerializer to convert document model to HTML.
      #
      # @param document [Document] The document to serialize
      # @return [Hash] Hash containing HTML, CSS, and images
      def serialize(document)
        html_serializer.serialize(document)
      end

      # Package HTML content and save as MHTML file.
      #
      # Delegates to MimePackager to create the MIME multipart file.
      #
      # @param html_parts [Hash] The HTML content to package
      #   - :html - The HTML content string
      #   - :css - The CSS stylesheet string
      #   - :images - Hash of image filenames to binary data
      # @param path [String] The output file path
      # @return [void]
      def package_and_save(html_parts, path)
        validate_write_path(path)

        # The MimePackager expects HTML content and resources
        packager = Infrastructure::MimePackager.new(
          html_parts[:html],
          html_parts[:images] || {}
        )
        packager.package(path)
      end

      private

      # Get or create MimeParser instance.
      #
      # @return [Infrastructure::MimeParser]
      def mime_parser
        @mime_parser ||= Infrastructure::MimeParser.new
      end

      # Get or create MimePackager instance.
      #
      # @return [Infrastructure::MimePackager]
      def mime_packager
        @mime_packager ||= Infrastructure::MimePackager.new
      end

      # Get or create HtmlDeserializer instance.
      #
      # @return [Serialization::HtmlDeserializer]
      def html_deserializer
        @html_deserializer ||= Serialization::HtmlDeserializer.new
      end

      # Get or create HtmlSerializer instance.
      #
      # @return [Serialization::HtmlSerializer]
      def html_serializer
        @html_serializer ||= Serialization::HtmlSerializer.new
      end
    end
  end
end

# Auto-register the MHTML handler
require_relative 'format_handler_registry'
Uniword::Formats::FormatHandlerRegistry.register(
  :mhtml,
  Uniword::Formats::MhtmlHandler
)
