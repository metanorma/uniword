# frozen_string_literal: true

require 'lutaml/model'
require_relative 'namespaces'
require_relative 'core_properties'
require_relative 'app_properties'
require_relative '../theme'
require_relative '../styles_configuration'
require_relative '../numbering_configuration'
require_relative '../document'

module Uniword
  module Ooxml
    # MHTML Package - Legacy Word format
    #
    # Represents .mht, .mhtml, and .doc files (HTML-based).
    # Uses MIME multipart format instead of ZIP packaging.
    #
    # This is the CORRECT OOP approach:
    # - ONE model class for the container
    # - Each part is a proper model attribute
    # - No serializer/deserializer anti-pattern
    #
    # @example Load MHTML file
    #   document = MhtmlPackage.from_file('document.mhtml')
    #
    # @example Save MHTML file
    #   MhtmlPackage.to_file(document, 'output.doc')
    class MhtmlPackage < Lutaml::Model::Serializable
      # Core document metadata
      attribute :core_properties, CoreProperties

      # Extended application properties
      attribute :app_properties, AppProperties

      # Document theme
      attribute :theme, Theme

      # Document styles configuration
      attribute :styles_configuration, StylesConfiguration

      # Document numbering configuration
      attribute :numbering_configuration, NumberingConfiguration

      # Load MHTML package from file
      #
      # @param path [String] Path to .mht, .mhtml, or .doc file
      # @return [Document] Loaded document
      def self.from_file(path)
        require_relative '../infrastructure/mime_parser'

        # Parse MIME content (DIFFERENT from ZIP!)
        parser = Infrastructure::MimeParser.new
        mime_parts = parser.parse(path)

        # Parse package from MIME parts
        package = from_mime_parts(mime_parts)

        # Parse main document from HTML
        # For MHTML, we convert HTML to Document structure
        document = if package.raw_html_content
                     # TODO: Implement HTML to Document conversion
                     # For now, create empty document with HTML preserved
                     doc = Document.new
                     doc.raw_html = package.raw_html_content
                     doc
                   else
                     Document.new
                   end

        # Transfer properties from package to document
        document.core_properties = package.core_properties if package.core_properties
        document.app_properties = package.app_properties if package.app_properties
        document.theme = package.theme if package.theme
        document.styles_configuration = package.styles_configuration if package.styles_configuration
        document.numbering_configuration = package.numbering_configuration if package.numbering_configuration

        document
      end

      # Create package from MIME parts
      #
      # @param mime_parts [Hash] Parsed MIME parts
      # @return [MhtmlPackage] Package object
      def self.from_mime_parts(mime_parts)
        package = new

        # Store HTML content (main document)
        package.raw_html_content = mime_parts['html']

        # Store filelist XML if present
        package.filelist_xml = mime_parts['filelist']

        # Store images
        package.images = mime_parts['images'] || {}

        # TODO: Parse properties from HTML metadata if present
        # MHTML files may embed document properties in HTML meta tags

        package
      end

      # Access raw HTML content
      attr_accessor :raw_html_content

      # Access filelist XML
      attr_accessor :filelist_xml

      # Access images hash
      attr_accessor :images

      # Get supported file extensions
      #
      # @return [Array<String>] Array of supported extensions
      def self.supported_extensions
        ['.mht', '.mhtml', '.doc']
      end

      # Save document to file
      #
      # @param document [Document] The document to save
      # @param path [String] Output path
      def self.to_file(document, path)
        require_relative '../infrastructure/mime_packager'

        # Create package
        package = new

        # Transfer properties to package
        package.core_properties = document.core_properties || CoreProperties.new
        package.app_properties = document.app_properties || AppProperties.new
        package.theme = document.theme
        package.styles_configuration = document.styles_configuration
        package.numbering_configuration = document.numbering_configuration

        # Convert document to HTML
        # For now, use raw HTML if available, otherwise serialize document to HTML
        package.raw_html_content = if document.respond_to?(:raw_html) && document.raw_html
                                     document.raw_html
                                   else
                                     # TODO: Implement Document to HTML conversion
                                     document_to_html(document)
                                   end

        # Get images from document
        package.images = extract_images(document)

        # Generate MIME parts and package
        mime_parts = package.to_mime_parts

        # Package and save
        packager = Infrastructure::MimePackager.new(
          package.raw_html_content,
          package.images,
          filelist_xml: package.filelist_xml
        )
        packager.package(path)
      end

      # Generate MIME parts hash (for compatibility)
      #
      # @return [Hash] MIME parts
      def to_mime_parts
        {
          'html' => raw_html_content,
          'filelist' => filelist_xml,
          'images' => images || {}
        }
      end

      # Convert Document to HTML
      #
      # @param document [Document] The document
      # @return [String] HTML content
      def self.document_to_html(document)
        # Basic HTML structure
        # TODO: Implement full Document to HTML serialization
        html = +'<html xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">'
        html << '<head><meta charset="utf-8"></head>'
        html << '<body>'

        # Serialize document body if present
        if document.body && document.body.elements
          document.body.elements.each do |element|
            html << element_to_html(element)
          end
        end

        html << '</body></html>'
        html
      end

      # Convert element to HTML
      #
      # @param element [Object] Document element
      # @return [String] HTML fragment
      def self.element_to_html(element)
        case element
        when Uniword::Paragraph
          paragraph_to_html(element)
        when Uniword::Table
          # TODO: Implement table to HTML
          '<table></table>'
        else
          ''
        end
      end

      # Convert paragraph to HTML
      #
      # @param paragraph [Paragraph] The paragraph
      # @return [String] HTML fragment
      def self.paragraph_to_html(paragraph)
        html = +'<p>'
        if paragraph.runs
          paragraph.runs.each do |run|
            html << run_to_html(run)
          end
        end
        html << '</p>'
        html
      end

      # Convert run to HTML
      #
      # @param run [Run] The run
      # @return [String] HTML fragment
      def self.run_to_html(run)
        html = +''
        text = run.text || ''

        # Apply formatting
        html << '<b>' if run.bold
        html << '<i>' if run.italic
        html << '<u>' if run.underline

        html << text

        html << '</u>' if run.underline
        html << '</i>' if run.italic
        html << '</b>' if run.bold

        html
      end

      # Extract images from document
      #
      # @param document [Document] The document
      # @return [Hash] Images hash
      def self.extract_images(document)
        # TODO: Implement image extraction from document
        {}
      end

      private_class_method :document_to_html, :element_to_html,
                           :paragraph_to_html, :run_to_html, :extract_images
    end
  end
end