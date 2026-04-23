# frozen_string_literal: true

require "lutaml/model"
# Theme, StylesConfiguration, NumberingConfiguration, Document are autoloaded via lib/uniword.rb

module Uniword
  module Ooxml
    # DOTX/DOTM Package - Word Template formats
    #
    # Represents .dotx (template) and .dotm (macro-enabled template) files.
    # Structure is identical to DOCX but used as document templates.
    # Templates often contain StyleSets and building blocks.
    #
    # This is the CORRECT OOP approach:
    # - ONE model class for the container
    # - Each XML part is a proper model attribute
    # - No serializer/deserializer anti-pattern
    #
    # @example Load template
    #   package = DotxPackage.from_file('template.dotx')
    #   package.core_properties.title = 'New Template Title'
    #   package.to_file('output.dotx')
    class DotxPackage < Lutaml::Model::Serializable
      # Core document metadata
      attribute :core_properties, CoreProperties

      # Extended application properties
      attribute :app_properties, AppProperties

      # Document theme
      attribute :theme, Uniword::Drawingml::Theme

      # Document styles configuration
      attribute :styles_configuration, Uniword::Wordprocessingml::StylesConfiguration

      # Document numbering configuration
      attribute :numbering_configuration, Uniword::Wordprocessingml::NumberingConfiguration

      # Document settings (word/settings.xml)
      attribute :settings, Uniword::Wordprocessingml::Settings

      # Document font table (word/fontTable.xml)
      attribute :font_table, Uniword::Wordprocessingml::FontTable

      # Document web settings (word/webSettings.xml)
      attribute :web_settings, Uniword::Wordprocessingml::WebSettings

      # Content types ([Content_Types].xml)
      attribute :content_types, Uniword::ContentTypes::Types

      # Package-level relationships (_rels/.rels)
      attribute :package_rels, Uniword::Ooxml::Relationships::PackageRelationships

      # Document-level relationships (word/_rels/document.xml.rels)
      attribute :document_rels, Uniword::Ooxml::Relationships::PackageRelationships

      # Footnotes (word/footnotes.xml)
      attribute :footnotes, Uniword::Wordprocessingml::Footnotes

      # Endnotes (word/endnotes.xml)
      attribute :endnotes, Uniword::Wordprocessingml::Endnotes

      # Load DOTX/DOTM package from file
      #
      # @param path [String] Path to .dotx or .dotm file
      # @return [Document] Loaded document (Generated::Wordprocessingml::DocumentRoot)
      def self.from_file(path)
        # Extract ZIP content
        extractor = Infrastructure::ZipExtractor.new
        zip_content = extractor.extract(path)

        # Parse package with properties and theme
        package = from_zip_content(zip_content)

        # Parse main document XML using generated classes
        # Document is aliased in lib/uniword.rb to Generated::Wordprocessingml::DocumentRoot
        document = if package.raw_document_xml
                     Uniword::Wordprocessingml::DocumentRoot.from_xml(package.raw_document_xml)
                   else
                     Uniword::Wordprocessingml::DocumentRoot.new
                   end

        # Transfer properties from package to document
        document.core_properties = package.core_properties if package.core_properties
        document.app_properties = package.app_properties if package.app_properties
        document.theme = package.theme if package.theme

        # Transfer model-based configurations
        document.styles_configuration = package.styles_configuration if package.styles_configuration
        document.numbering_configuration = package.numbering_configuration if package.numbering_configuration
        document.settings = package.settings if package.settings
        document.font_table = package.font_table if package.font_table
        document.web_settings = package.web_settings if package.web_settings
        document.document_rels = package.document_rels if package.document_rels
        document.content_types = package.content_types if package.content_types
        document.package_rels = package.package_rels if package.package_rels
        document.footnotes = package.footnotes if package.footnotes
        document.endnotes = package.endnotes if package.endnotes

        document
      end

      # Create package from extracted ZIP content
      #
      # @param zip_content [Hash] Extracted ZIP files
      # @return [DotxPackage] Package object
      def self.from_zip_content(zip_content)
        package = new

        # Parse lutaml-model files
        package.core_properties = CoreProperties.from_xml(zip_content["docProps/core.xml"]) if zip_content["docProps/core.xml"]

        package.app_properties = AppProperties.from_xml(zip_content["docProps/app.xml"]) if zip_content["docProps/app.xml"]

        package.theme = Uniword::Drawingml::Theme.from_xml(zip_content["word/theme/theme1.xml"]) if zip_content["word/theme/theme1.xml"]

        # Parse styles and numbering as models
        package.styles_configuration = Uniword::Wordprocessingml::StylesConfiguration.from_xml(zip_content["word/styles.xml"]) if zip_content["word/styles.xml"]

        package.numbering_configuration = Uniword::Wordprocessingml::NumberingConfiguration.from_xml(zip_content["word/numbering.xml"]) if zip_content["word/numbering.xml"]

        # Store raw document XML (will be parsed by DotxHandler)
        package.raw_document_xml = zip_content["word/document.xml"] if zip_content["word/document.xml"]

        # Parse settings
        if zip_content["word/settings.xml"]
          package.settings = Uniword::Wordprocessingml::Settings.from_xml(
            zip_content["word/settings.xml"]
          )
        end

        # Parse font table
        if zip_content["word/fontTable.xml"]
          package.font_table = Uniword::Wordprocessingml::FontTable.from_xml(
            zip_content["word/fontTable.xml"]
          )
        end

        # Parse web settings
        if zip_content["word/webSettings.xml"]
          package.web_settings = Uniword::Wordprocessingml::WebSettings.from_xml(
            zip_content["word/webSettings.xml"]
          )
        end

        # Parse content types
        if zip_content["[Content_Types].xml"]
          package.content_types = Uniword::ContentTypes::Types.from_xml(
            zip_content["[Content_Types].xml"]
          )
        end

        # Parse package relationships
        if zip_content["_rels/.rels"]
          package.package_rels = Uniword::Ooxml::Relationships::PackageRelationships.from_xml(
            zip_content["_rels/.rels"]
          )
        end

        # Parse document relationships
        if zip_content["word/_rels/document.xml.rels"]
          package.document_rels = Uniword::Ooxml::Relationships::PackageRelationships.from_xml(
            zip_content["word/_rels/document.xml.rels"]
          )
        end

        # Parse footnotes
        if zip_content["word/footnotes.xml"]
          package.footnotes = Uniword::Wordprocessingml::Footnotes.from_xml(
            zip_content["word/footnotes.xml"]
          )
        end

        # Parse endnotes
        if zip_content["word/endnotes.xml"]
          package.endnotes = Uniword::Wordprocessingml::Endnotes.from_xml(
            zip_content["word/endnotes.xml"]
          )
        end

        package
      end

      # Access raw document XML (for compatibility)
      attr_accessor :raw_document_xml

      # Get supported file extensions
      #
      # @return [Array<String>] Array of supported extensions
      def self.supported_extensions
        [".dotx", ".dotm"]
      end

      # Save document to file
      #
      # @param document [Document] The document to save (Generated::Wordprocessingml::DocumentRoot)
      # @param path [String] Output path
      def self.to_file(document, path, profile: nil)
        # Create package
        package = new

        # Transfer properties to package
        package.core_properties = document.core_properties || CoreProperties.new
        package.app_properties = document.app_properties || AppProperties.new
        package.theme = document.theme

        # Transfer model-based configurations
        package.styles_configuration = document.styles_configuration
        package.numbering_configuration = document.numbering_configuration

        # Serialize main document
        package.raw_document_xml = document.to_xml(encoding: "UTF-8")

        # Generate ZIP content
        zip_content = package.to_zip_content

        # Add required OOXML infrastructure files
        add_required_files(zip_content)

        # Package and save
        packager = Infrastructure::ZipPackager.new
        packager.package(zip_content, path)
      end

      # Save package to file
      #
      # @param path [String] Output path
      def to_file(path)
        zip_content = to_zip_content

        packager = Infrastructure::ZipPackager.new
        packager.package(zip_content, path)
      end

      # Generate ZIP content hash
      #
      # @return [Hash] File paths => content
      def to_zip_content
        content = {}

        # Serialize lutaml-model files with prefix: false
        if core_properties
          content["docProps/core.xml"] =
            core_properties.to_xml(encoding: "UTF-8", prefix: false)
        end
        if app_properties
          content["docProps/app.xml"] =
            app_properties.to_xml(encoding: "UTF-8", prefix: false)
        end

        # Theme serialization (no raw XML fallback)
        content["word/theme/theme1.xml"] = theme.to_xml(encoding: "UTF-8") if theme

        # Serialize model-based configurations
        if styles_configuration
          content["word/styles.xml"] =
            styles_configuration.to_xml(encoding: "UTF-8")
        end

        if numbering_configuration
          content["word/numbering.xml"] =
            numbering_configuration.to_xml(encoding: "UTF-8")
        end

        # Serialize main document (word/document.xml)
        if @document
          content["word/document.xml"] = @document.to_xml(encoding: "UTF-8")
        elsif @raw_document_xml
          # Fallback to raw XML if document wasn't parsed yet
          content["word/document.xml"] = @raw_document_xml
        end

        # Serialize settings
        if settings
          content["word/settings.xml"] =
            settings.to_xml(encoding: "UTF-8")
        end

        # Serialize font table
        if font_table
          content["word/fontTable.xml"] =
            font_table.to_xml(encoding: "UTF-8")
        end

        # Serialize web settings
        if web_settings
          content["word/webSettings.xml"] =
            web_settings.to_xml(encoding: "UTF-8")
        end

        # Serialize content types
        if content_types
          content["[Content_Types].xml"] =
            content_types.to_xml(declaration: true)
        end

        # Serialize package relationships
        if package_rels
          content["_rels/.rels"] =
            package_rels.to_xml(declaration: true)
        end

        # Serialize document relationships
        if document_rels
          content["word/_rels/document.xml.rels"] =
            document_rels.to_xml(declaration: true)
        end

        # Serialize footnotes
        if footnotes
          content["word/footnotes.xml"] =
            footnotes.to_xml(encoding: "UTF-8")
        end

        # Serialize endnotes
        if endnotes
          content["word/endnotes.xml"] =
            endnotes.to_xml(encoding: "UTF-8")
        end

        content
      end

      # Add required OOXML files for a valid DOTX/DOTM package
      #
      # @param zip_content [Hash] The ZIP content hash
      # @return [void]
      def self.add_required_files(zip_content)
        # Add [Content_Types].xml if not present
        unless zip_content["[Content_Types].xml"]
          zip_content["[Content_Types].xml"] =
            Uniword::ContentTypes.generate.to_xml(declaration: true)
        end

        # Add _rels/.rels if not present
        unless zip_content["_rels/.rels"]
          zip_content["_rels/.rels"] =
            Uniword::Ooxml::Relationships::PackageRelationships.generate_package_rels.to_xml(declaration: true)
        end

        # Add word/_rels/document.xml.rels if not present
        return if zip_content["word/_rels/document.xml.rels"]

        zip_content["word/_rels/document.xml.rels"] =
          Uniword::Ooxml::Relationships::Relationships.generate_document_rels.to_xml(
            declaration: true
          )
      end

      private_class_method :add_required_files
    end
  end
end
