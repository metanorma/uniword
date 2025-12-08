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

# Namespace modules with cross-dependencies MUST be eagerly loaded
# These cannot use autoload because:
# 1. Format handlers (loaded at line 220) depend on these namespaces
# 2. Format handlers execute self-registration code at load time (side effects)
# 3. Cross-dependencies between namespaces prevent deferred loading
# 4. Autoload triggers inside module definition fail (NameError before autoload executes)
require_relative 'uniword/wordprocessingml'
require_relative 'uniword/wp_drawing'
require_relative 'uniword/drawingml'
require_relative 'uniword/vml'
require_relative 'uniword/math'
require_relative 'uniword/shared_types'

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
  # NOTE: These constants require namespaces to be eagerly loaded (see lines 18-23)
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
  autoload :ThemeWriter, 'uniword/theme_writer'
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
  module Stylesets
    autoload :Package, 'uniword/stylesets/package'
    autoload :YamlStyleSetLoader, 'uniword/stylesets/yaml_styleset_loader'
  end

  # Autoload infrastructure
  module Infrastructure
    autoload :ZipExtractor, 'uniword/infrastructure/zip_extractor'
    autoload :ZipPackager, 'uniword/infrastructure/zip_packager'
    autoload :MimeParser, 'uniword/infrastructure/mime_parser'
    autoload :MimePackager, 'uniword/infrastructure/mime_packager'
  end

  autoload :ContentTypes, 'uniword/content_types'
  autoload :DocumentProperties, 'uniword/document_properties'
  autoload :Glossary, 'uniword/glossary'

  # Autoload OOXML support
  module Ooxml
    autoload :Relationships, 'uniword/ooxml/relationships'
    autoload :DocxPackage, 'uniword/ooxml/docx_package'
    autoload :DotxPackage, 'uniword/ooxml/dotx_package'
    autoload :ThmxPackage, 'uniword/ooxml/thmx_package'
    autoload :MhtmlPackage, 'uniword/ooxml/mhtml_package'

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

  # === Top-Level Classes (Comprehensive Autoload) ===
  # All top-level classes in lib/uniword/*.rb use autoload for maintenance simplicity

  # Document structure and components
  autoload :Bibliography, 'uniword/bibliography'
  autoload :Bookmark, 'uniword/bookmark'
  autoload :Chart, 'uniword/chart'
  autoload :Comment, 'uniword/comment'
  autoload :CommentRange, 'uniword/comment_range'
  autoload :CommentsPart, 'uniword/comments_part'
  autoload :DocumentVariables, 'uniword/document_variables'
  autoload :Endnote, 'uniword/endnote'
  autoload :Field, 'uniword/field'
  autoload :Footer, 'uniword/footer'
  autoload :Footnote, 'uniword/footnote'
  autoload :Header, 'uniword/header'
  autoload :Hyperlink, 'uniword/hyperlink'
  autoload :Image, 'uniword/image'
  autoload :MathEquation, 'uniword/math_equation'
  autoload :Picture, 'uniword/picture'
  autoload :Revision, 'uniword/revision'
  autoload :Section, 'uniword/section'
  autoload :SectionProperties, 'uniword/section_properties'
  autoload :TextBox, 'uniword/text_box'
  autoload :TextFrame, 'uniword/text_frame'
  autoload :TrackedChanges, 'uniword/tracked_changes'

  # Table components
  autoload :TableBorder, 'uniword/table_border'
  autoload :TableCell, 'uniword/table_cell'
  autoload :TableColumn, 'uniword/table_column'
  autoload :TableRow, 'uniword/table_row'

  # Formatting and styling
  autoload :ColumnConfiguration, 'uniword/column_configuration'
  autoload :Extension, 'uniword/extension'
  autoload :ExtensionList, 'uniword/extension_list'
  autoload :ExtraColorSchemeList, 'uniword/extra_color_scheme_list'
  autoload :FormatScheme, 'uniword/format_scheme'
  autoload :LineNumbering, 'uniword/line_numbering'
  autoload :NumberingDefinition, 'uniword/numbering_definition'
  autoload :NumberingInstance, 'uniword/numbering_instance'
  autoload :NumberingLevel, 'uniword/numbering_level'
  autoload :ObjectDefaults, 'uniword/object_defaults'
  autoload :PageBorders, 'uniword/page_borders'
  autoload :ParagraphBorder, 'uniword/paragraph_border'
  autoload :Shading, 'uniword/shading'
  autoload :StructuredDocumentTagProperties, 'uniword/structured_document_tag_properties'
  autoload :TabStop, 'uniword/tab_stop'

  # Infrastructure and utilities
  autoload :Builder, 'uniword/builder'
  autoload :Customxml, 'uniword/customxml'
  autoload :ElementRegistry, 'uniword/element_registry'
  autoload :FormatConverter, 'uniword/format_converter'
  autoload :LazyLoader, 'uniword/lazy_loader'
  autoload :Logger, 'uniword/logger'
  autoload :StreamingParser, 'uniword/streaming_parser'

  # Additional namespace loaders (Office ML variants)
  autoload :Office, 'uniword/office'
  autoload :Presentationml, 'uniword/presentationml'
  autoload :Spreadsheetml, 'uniword/spreadsheetml'
  autoload :VmlOffice, 'uniword/vml_office'
  autoload :Wordprocessingml2010, 'uniword/wordprocessingml_2010'
  autoload :Wordprocessingml2013, 'uniword/wordprocessingml_2013'
  autoload :Wordprocessingml2016, 'uniword/wordprocessingml_2016'

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
