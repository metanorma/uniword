# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Mhtml
    # MHTML Package - MIME-based Word format
    #
    # Represents .mht, .mhtml, and .doc files (HTML-based).
    # Uses MIME multipart format instead of ZIP packaging.
    #
    # IMPORTANT: This is COMPLETELY SEPARATE from OOXML DocxPackage.
    # - OOXML uses ZIP + XML parts
    # - MHTML uses MIME + HTML content
    # - They share NO classes!
    #
    # @example Load MHTML file
    #   document = MhtmlPackage.from_file('document.mhtml')
    #
    # @example Save MHTML file
    #   MhtmlPackage.to_file(document, 'output.doc')
    class MhtmlPackage < Lutaml::Model::Serializable
      # Core document metadata (MHTML-specific)
      attribute :core_properties, :hash, default: -> { {} }

      # Extended application properties (MHTML-specific)
      attribute :app_properties, :hash, default: -> { {} }

      # Document theme (MHTML-specific, NOT Drawingml::Theme)
      attribute :theme, Theme

      # Document styles configuration (MHTML-specific, NOT Wordprocessingml::StylesConfiguration)
      attribute :styles_configuration, StylesConfiguration

      # Document numbering configuration (MHTML-specific, NOT Wordprocessingml::NumberingConfiguration)
      attribute :numbering_configuration, NumberingConfiguration

      # Load MHTML package from file
      #
      # @param path [String] Path to .mht, .mhtml, or .doc file
      # @return [Document] Loaded document
      def self.from_file(path)
        # Parse MIME content (DIFFERENT from ZIP!)
        parser = Infrastructure::MimeParser.new
        mime_parts = parser.parse(path)

        # Parse package from MIME parts
        package = from_mime_parts(mime_parts)

        # Create MHTML document (NOT OOXML Document!)
        document = Document.new
        document.raw_html = package.raw_html_content if package.raw_html_content

        # Transfer properties from package to document
        document.core_properties = package.core_properties if package.core_properties
        document.app_properties = package.app_properties if package.app_properties

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
        # Create package
        package = new

        # Transfer properties to package
        package.core_properties = document.core_properties || {}
        package.app_properties = document.app_properties || {}
        package.theme = document.theme if document.respond_to?(:theme)
        package.styles_configuration = document.styles_configuration if document.respond_to?(:styles_configuration)
        package.numbering_configuration = document.numbering_configuration if document.respond_to?(:numbering_configuration)

        # Convert document to HTML
        package.raw_html_content = if document.respond_to?(:raw_html) && document.raw_html
                                     document.raw_html
                                   else
                                     document_to_html(document)
                                   end

        # Get images from document
        package.images = extract_images(document)

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
        document.respond_to?(:to_html_document) ? document.to_html_document : document.to_html
      end

      # Extract images from document
      #
      # @param document [Document] The document
      # @return [Hash] Images hash
      def self.extract_images(_document)
        # TODO: Implement image extraction from document
        {}
      end

      private_class_method :document_to_html, :extract_images
    end
  end
end
