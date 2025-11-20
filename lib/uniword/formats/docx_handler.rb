# frozen_string_literal: true

require_relative 'base_handler'
require_relative '../infrastructure/zip_extractor'
require_relative '../infrastructure/zip_packager'
require_relative '../serialization/ooxml_deserializer'
require_relative '../serialization/ooxml_serializer'

module Uniword
  module Formats
    # Handles DOCX (Office Open XML) format files.
    #
    # Responsibility: Coordinate DOCX file operations by delegating to
    # infrastructure and serialization classes. Follows Single Responsibility
    # Principle - the handler orchestrates but doesn't implement details.
    #
    # DOCX files are ZIP archives containing XML files following the OOXML standard.
    # This handler uses:
    # - ZipExtractor for reading ZIP content
    # - ZipPackager for creating ZIP files
    # - OoxmlDeserializer for converting XML to Document
    # - OoxmlSerializer for converting Document to XML
    #
    # @example Read a DOCX file
    #   handler = Uniword::Formats::DocxHandler.new
    #   document = handler.read("document.docx")
    #
    # @example Write a DOCX file
    #   handler = Uniword::Formats::DocxHandler.new
    #   handler.write(document, "output.docx")
    class DocxHandler < BaseHandler
      # Get supported file extensions.
      #
      # @return [Array<String>] Array of supported extensions
      def supported_extensions
        ['.docx']
      end

      protected

      # Extract content from a DOCX file.
      #
      # Delegates to ZipExtractor to extract the ZIP archive contents.
      #
      # @param path [String] The file path
      # @return [Hash<String, String>] Hash mapping file paths to content
      def extract_content(path)
        zip_extractor.extract(path)
      end

      # Deserialize OOXML content into a Document.
      #
      # Delegates to OoxmlDeserializer to parse XML and build document model.
      #
      # @param content [Hash<String, String>] The extracted ZIP content
      # @return [Document] The deserialized document
      def deserialize(content)
        ooxml_deserializer.deserialize(content)
      end

      # Serialize a Document into OOXML format.
      #
      # Delegates to OoxmlSerializer to convert document model to XML.
      #
      # @param document [Document] The document to serialize
      # @return [Hash<String, String>] Hash mapping file paths to XML content
      def serialize(document)
        ooxml_serializer.serialize_package(document)
      end

      # Package OOXML content and save as DOCX file.
      #
      # Delegates to ZipPackager to create the ZIP archive.
      #
      # @param content [Hash<String, String>] The OOXML content to package
      # @param path [String] The output file path
      # @return [void]
      def package_and_save(content, path)
        validate_write_path(path)
        zip_packager.package(content, path)
      end

      private

      # Get or create ZipExtractor instance.
      #
      # @return [Infrastructure::ZipExtractor]
      def zip_extractor
        @zip_extractor ||= Infrastructure::ZipExtractor.new
      end

      # Get or create ZipPackager instance.
      #
      # @return [Infrastructure::ZipPackager]
      def zip_packager
        @zip_packager ||= Infrastructure::ZipPackager.new
      end

      # Get or create OoxmlDeserializer instance.
      #
      # @return [Serialization::OoxmlDeserializer]
      def ooxml_deserializer
        @ooxml_deserializer ||= Serialization::OoxmlDeserializer.new
      end

      # Get or create OoxmlSerializer instance.
      #
      # @return [Serialization::OoxmlSerializer]
      def ooxml_serializer
        @ooxml_serializer ||= Serialization::OoxmlSerializer.new
      end
    end
  end
end

# Auto-register the DOCX handler
require_relative 'format_handler_registry'
Uniword::Formats::FormatHandlerRegistry.register(
  :docx,
  Uniword::Formats::DocxHandler
)
