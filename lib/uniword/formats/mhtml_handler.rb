# frozen_string_literal: true

require_relative 'base_handler'
require_relative '../infrastructure/mime_parser'
require_relative '../infrastructure/mime_packager'
# TEMPORARY: HTML importer disabled during v2.0 migration (uses archived v1.x classes)
# Will be updated post-v2.0.0 to use generated classes
# require_relative '../html_importer'

module Uniword
  module Formats
    # Handles MHTML (MIME HTML) format files.
    #
    # Responsibility: Coordinate MHTML file operations by delegating to
    # infrastructure classes. Follows Single Responsibility
    # Principle - the handler orchestrates but doesn't implement details.
    #
    # MHTML files are MIME multipart documents containing HTML and embedded
    # resources. This handler uses:
    # - MimeParser for reading MIME content
    # - MimePackager for creating MIME files
    # - HtmlImporter for converting HTML to Document
    # - Document#to_html for converting Document to HTML
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
      # TEMPORARY: HTML import disabled during v2.0 migration.
      # Will be re-enabled post-v2.0.0 with updated HtmlImporter
      # that uses generated classes instead of v1.x archived classes.
      #
      # @param mime_parts [Hash] The extracted MIME parts
      # @return [Document] Empty document (HTML import not yet supported in v2.0)
      def deserialize(_mime_parts)
        # TODO: Re-enable HTML import after updating HtmlImporter for v2.0
        # raise UnsupportedOperationError,
        #   "MHTML/HTML import temporarily disabled in v2.0. " \
        #   "Will be re-enabled in a future release with updated HtmlImporter."

        # For now, return empty document
        Document.new
      end

      # Serialize a Document into HTML format.
      #
      # Uses Document#to_html to convert document model to HTML.
      #
      # @param document [Document] The document to serialize
      # @return [Hash] Hash containing HTML, CSS, and images
      def serialize(document)
        {
          html: document.to_html,
          images: extract_images(document)
        }
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

      # Extract images from document for MHTML packaging
      #
      # @param document [Document] The document
      # @return [Hash] Hash of image filenames to binary data
      def extract_images(document)
        images = {}
        document.images.each do |image|
          # Store image data if available
          if image.respond_to?(:data) && image.data
            filename = image.filename || "image_#{image.object_id}.png"
            images[filename] = image.data
          end
        end
        images
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
