# frozen_string_literal: true

require 'lutaml/model'
require 'nokogiri'
require 'zip'

# Configure lutaml-model to use Nokogiri adapter for XML
require 'lutaml/model/xml_adapter/nokogiri_adapter'
Lutaml::Model::Config.configure do |config|
  config.xml_adapter = Lutaml::Model::Xml::NokogiriAdapter
end

require_relative 'uniword/version'

# Load OOXML namespaces FIRST (needed by generated classes)
require_relative 'uniword/ooxml/namespaces'

# Load all generated classes
require_relative 'uniword/wordprocessingml'
require_relative 'uniword/drawingml'
require_relative 'uniword/math'
require_relative 'uniword/shared_types'
require_relative 'uniword/content_types'
require_relative 'uniword/document_properties'

# Load extension modules that add convenience methods to generated classes

# Uniword is a comprehensive Ruby library for reading and writing Microsoft Word
# documents in DOCX format using a schema-driven architecture.
#
# Version 2.0 uses generated classes from YAML schemas covering 760 elements
# across 22 OOXML namespaces with perfect round-trip fidelity.
#
# @example Create a simple document
#   doc = Uniword::Document.new
#   doc.add_paragraph("Hello World", bold: true)
#   doc.save('output.docx')
#
# @example Read an existing document
#   doc = Uniword.load('input.docx')
#   puts doc.text
#   doc.paragraphs.each { |p| puts p.text }
#
# @example Apply theme and StyleSet
#   doc = Uniword::Document.new
#   doc.add_paragraph("Hello World")
#   doc.apply_theme('celestial')
#   doc.apply_styleset('distinctive')
#   doc.save('output.docx')
#
# @see Document Main document class (alias for Wordprocessingml::DocumentRoot)
# @see DocumentFactory Factory for reading documents
module Uniword
  # Re-export generated classes as primary API
  # These are the schema-generated classes from lib/uniword/wordprocessingml/
  Document = Wordprocessingml::DocumentRoot
  Body = Wordprocessingml::Body
  Paragraph = Wordprocessingml::Paragraph
  Run = Wordprocessingml::Run
  Table = Wordprocessingml::Table
  TableRow = Wordprocessingml::TableRow
  TableCell = Wordprocessingml::TableCell

  # Properties classes
  ParagraphProperties = Ooxml::WordProcessingML::ParagraphProperties
  RunProperties = Ooxml::WordProcessingML::RunProperties
  TableProperties = Ooxml::WordProcessingML::TableProperties
  SectionProperties = Wordprocessingml::SectionProperties

  # Additional element classes
  Hyperlink = Wordprocessingml::Hyperlink
  BookmarkStart = Wordprocessingml::BookmarkStart
  BookmarkEnd = Wordprocessingml::BookmarkEnd

  # Math support
  MathElement = Math::OMath

  # Autoload infrastructure classes (still needed)
  autoload :DocumentFactory, 'uniword/document_factory'
  autoload :DocumentWriter, 'uniword/document_writer'
  autoload :FormatDetector, 'uniword/format_detector'

  # Autoload error classes
  autoload :Error, 'uniword/errors'
  autoload :FileNotFoundError, 'uniword/errors'
  autoload :InvalidFormatError, 'uniword/errors'
  autoload :CorruptedFileError, 'uniword/errors'
  autoload :ValidationError, 'uniword/errors'
  autoload :ReadOnlyError, 'uniword/errors'
  autoload :DependencyError, 'uniword/errors'
  autoload :UnsupportedOperationError, 'uniword/errors'
  autoload :ConversionError, 'uniword/errors'

  # Autoload styles
  autoload :StylesConfiguration, 'uniword/styles_configuration'
  autoload :Style, 'uniword/style'

  # Autoload themes
  autoload :ThemeModel, 'uniword/theme'
  autoload :ColorScheme, 'uniword/color_scheme'
  autoload :FontScheme, 'uniword/font_scheme'

  # Autoload stylesets
  autoload :StyleSet, 'uniword/styleset'

  # Autoload numbering
  autoload :NumberingConfiguration, 'uniword/numbering_configuration'

  # Autoload theme infrastructure (renamed to avoid conflict with Theme class)
  autoload :ThemeLoader, 'uniword/theme/theme_loader'
  autoload :ThemePackageReader, 'uniword/theme/theme_package_reader'

  # Autoload styleset infrastructure
  autoload :StylesetLoader, 'uniword/stylesets/styleset_loader'
  autoload :StylesetXmlParser, 'uniword/stylesets/styleset_xml_parser'

  # Autoload format handlers
  module Formats
    autoload :BaseHandler, 'uniword/formats/base_handler'
    autoload :DocxHandler, 'uniword/formats/docx_handler'
    autoload :MhtmlHandler, 'uniword/formats/mhtml_handler'
    autoload :FormatHandlerRegistry, 'uniword/formats/format_handler_registry'
  end

  # Autoload infrastructure
  module Infrastructure
    autoload :ZipExtractor, 'uniword/infrastructure/zip_extractor'
    autoload :ZipPackager, 'uniword/infrastructure/zip_packager'
    autoload :MimeParser, 'uniword/infrastructure/mime_parser'
    autoload :MimePackager, 'uniword/infrastructure/mime_packager'
  end

  # Autoload OOXML support
  module Ooxml
    autoload :ContentTypes, 'uniword/ooxml/content_types'
    autoload :Relationships, 'uniword/ooxml/relationships'
    autoload :DocxPackage, 'uniword/ooxml/docx_package'

    # Namespace definitions
    module Namespaces
      WORDPROCESSINGML = 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
      DRAWINGML = 'http://schemas.openxmlformats.org/drawingml/2006/main'
      RELATIONSHIPS = 'http://schemas.openxmlformats.org/officeDocument/2006/relationships'
      MATH = 'http://schemas.openxmlformats.org/officeDocument/2006/math'
    end
  end

  # Schema infrastructure (v2.0)
  module Schema
    autoload :SchemaLoader, 'uniword/schema/schema_loader'
    autoload :ModelGenerator, 'uniword/schema/model_generator'
  end

  # Autoload CLI
  autoload :CLI, 'uniword/cli'

  # Eagerly load format handlers to trigger self-registration
  require_relative 'uniword/formats/docx_handler'
  require_relative 'uniword/formats/mhtml_handler'

  # Module-level convenience methods
  class << self
    # Create a new document
    #
    # @return [Document] New document instance
    def new
      Document.new
    end

    # Load document from file
    #
    # @param path [String] File path
    # @return [Document] Loaded document
    def load(path)
      DocumentFactory.from_file(path)
    end

    alias open load

    # Import HTML into a Uniword document
    #
    # TEMPORARY: Disabled during v2.0 migration (HtmlImporter uses archived v1.x classes)
    # Will be re-enabled post-v2.0.0 with updated HtmlImporter using generated classes.
    #
    # @param html [String] HTML content
    # @param options [Hash] Import options
    # @return [Document] The generated document
    def from_html(_html, **_options)
      raise UnsupportedOperationError,
            'HTML import temporarily disabled in v2.0. ' \
            'Will be re-enabled in a future release with updated HtmlImporter.'
    end

    # Convert HTML file to Word DOCX format
    #
    # TEMPORARY: Disabled during v2.0 migration
    #
    # @param html_file [String] Path to HTML file
    # @param output [String] Path to output DOCX file
    # @param options [Hash] Import options
    # @return [void]
    def html_to_docx(_html_file, _output, **_options)
      raise UnsupportedOperationError,
            'HTML import temporarily disabled in v2.0. ' \
            'Will be re-enabled in a future release.'
    end

    # Convert HTML file to Word DOC (MHTML) format
    #
    # TEMPORARY: Disabled during v2.0 migration
    #
    # @param html_file [String] Path to HTML file
    # @param output [String] Path to output DOC file
    # @param options [Hash] Import options
    # @return [void]
    def html_to_doc(_html_file, _output, **_options)
      raise UnsupportedOperationError,
            'HTML import temporarily disabled in v2.0. ' \
            'Will be re-enabled in a future release.'
    end
  end
end
