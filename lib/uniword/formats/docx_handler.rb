# frozen_string_literal: true

require_relative 'base_handler'
require_relative '../infrastructure/zip_extractor'
require_relative '../infrastructure/zip_packager'
require_relative '../ooxml/docx_package'

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
      # Uses DocxPackage to parse properties and theme, then parses
      # the main document XML using Document.from_xml().
      #
      # Document is aliased to Generated::Wordprocessingml::DocumentRoot
      # in lib/uniword.rb, so this uses the generated v2.0 classes.
      #
      # @param content [Hash<String, String>] The extracted ZIP content
      # @return [Document] The deserialized document (Generated class)
      def deserialize(content)
        # Load package with properties and theme
        package = Ooxml::DocxPackage.from_zip_content(content)

        # Parse main document XML using generated classes
        # Document is aliased in lib/uniword.rb to Generated::Wordprocessingml::DocumentRoot
        document = if package.raw_document_xml
                     Document.from_xml(package.raw_document_xml)
                   else
                     Document.new
                   end

        # Transfer properties from package to document
        document.core_properties = package.core_properties if package.core_properties
        document.app_properties = package.app_properties if package.app_properties
        document.theme = package.theme if package.theme
        
        # Transfer model-based configurations
        document.styles_configuration = package.styles_configuration if package.styles_configuration
        document.numbering_configuration = package.numbering_configuration if package.numbering_configuration

        document
      end

      # Serialize a Document into OOXML format.
      #
      # Uses Document.to_xml() for main content and DocxPackage
      # for properties and theme.
      #
      # @param document [Document] The document to serialize
      # @return [Hash<String, String>] Hash mapping file paths to XML content
      def serialize(document)
        # Create package
        package = Ooxml::DocxPackage.new

        # Transfer properties to package
        package.core_properties = document.core_properties || Ooxml::CoreProperties.new
        package.app_properties = document.app_properties || Ooxml::AppProperties.new
        package.theme = document.theme

        # Serialize main document
        package.raw_document_xml = document.to_xml(encoding: 'UTF-8')

        # Transfer model-based configurations
        package.styles_configuration = document.styles_configuration
        package.numbering_configuration = document.numbering_configuration

        # Convert package to ZIP content
        zip_content = package.to_zip_content
        
        # Add required OOXML infrastructure files
        add_required_files(zip_content)
        
        zip_content
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
      
      # Add required OOXML files for a valid DOCX package
      #
      # @param zip_content [Hash] The ZIP content hash
      # @return [void]
      def add_required_files(zip_content)
        require_relative '../ooxml/content_types'
        require_relative '../ooxml/relationships'
        
        # Add [Content_Types].xml if not present
        unless zip_content['[Content_Types].xml']
          zip_content['[Content_Types].xml'] = Ooxml::ContentTypes.generate
        end
        
        # Add _rels/.rels if not present
        unless zip_content['_rels/.rels']
          zip_content['_rels/.rels'] = Ooxml::Relationships.generate_package_rels
        end
        
        # Add word/_rels/document.xml.rels if not present
        unless zip_content['word/_rels/document.xml.rels']
          zip_content['word/_rels/document.xml.rels'] = Ooxml::Relationships.generate_document_rels
        end
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
