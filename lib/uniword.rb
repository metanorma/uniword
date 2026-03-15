# frozen_string_literal: true

require 'lutaml/model'
require 'nokogiri'
require 'zip'

# Configure lutaml-model to use Nokogiri adapter for XML
Lutaml::Model::Config.xml_adapter_type = :nokogiri

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
  # Version constant
  autoload :VERSION, 'uniword/version'

  # === Namespace Modules (autoload) ===
  # All autoloads MUST be inside the module they're registering constants for

  # OOXML module with Namespaces autoload chain
  autoload :Ooxml, 'uniword/ooxml'

  # Properties module
  autoload :Properties, 'uniword/properties'

  # XML namespace modules
  autoload :Wordprocessingml, 'uniword/wordprocessingml'
  autoload :WpDrawing, 'uniword/wp_drawing'
  autoload :Drawingml, 'uniword/drawingml'
  autoload :Vml, 'uniword/vml'
  autoload :Math, 'uniword/math'
  autoload :SharedTypes, 'uniword/shared_types'

  # === API Aliases (WordProcessingML namespace) ===
  # Re-export generated classes as primary API
  Document = Wordprocessingml::DocumentRoot
  Body = Wordprocessingml::Body
  Paragraph = Wordprocessingml::Paragraph
  Run = Wordprocessingml::Run
  Table = Wordprocessingml::Table
  TableRow = Wordprocessingml::TableRow
  TableCell = Wordprocessingml::TableCell

  # Properties classes
  ParagraphProperties = Wordprocessingml::ParagraphProperties
  RunProperties = Wordprocessingml::RunProperties
  TableProperties = Wordprocessingml::TableProperties
  SectionProperties = Wordprocessingml::SectionProperties

  # Additional element classes
  Hyperlink = Wordprocessingml::Hyperlink
  BookmarkStart = Wordprocessingml::BookmarkStart
  BookmarkEnd = Wordprocessingml::BookmarkEnd

  # SDT properties (WordProcessingML namespace, aliased for convenience)
  StructuredDocumentTagProperties = Wordprocessingml::StructuredDocumentTagProperties

  # Math support
  MathElement = Math::OMath

  # === DrawingML Convenience Aliases ===
  # Classes are in Drawingml namespace, These must be constant assignments,
  # not autoload, because the files define Uniword::Drawingml::ClassName
  Theme = Drawingml::Theme
  ThemeModel = Drawingml::Theme
  ColorScheme = Drawingml::ColorScheme
  FontScheme = Drawingml::FontScheme
  FormatScheme = Drawingml::FormatScheme
  ObjectDefaults = Drawingml::ObjectDefaults
  ExtensionList = Drawingml::ExtensionList
  Extension = Drawingml::Extension
  ExtraColorSchemeList = Drawingml::ExtraColorSchemeList
  FillStyleList = Drawingml::FillStyleList
  LineStyleList = Drawingml::LineStyleList
  EffectStyleList = Drawingml::EffectStyleList
  BackgroundFillStyleList = Drawingml::BackgroundFillStyleList

  # === Infrastructure Classes (autoload) ===
  autoload :DocumentFactory, 'uniword/document_factory'
  autoload :DocumentWriter, 'uniword/document_writer'
  autoload :ThemeWriter, 'uniword/theme_writer'
  autoload :FormatDetector, 'uniword/format_detector'

  # Error classes
  autoload :Error, 'uniword/errors'
  autoload :FileNotFoundError, 'uniword/errors'
  autoload :InvalidFormatError, 'uniword/errors'
  autoload :CorruptedFileError, 'uniword/errors'
  autoload :ValidationError, 'uniword/errors'
  autoload :ReadOnlyError, 'uniword/errors'
  autoload :DependencyError, 'uniword/errors'
  autoload :UnsupportedOperationError, 'uniword/errors'
  autoload :ConversionError, 'uniword/errors'

  # Styles (moved to wordprocessingml/styles/)
  autoload :Styles, 'uniword/wordprocessingml/styles'

  # Namespace autoloads (autoloads done in immediate parent namespace files)
  autoload :Template, 'uniword/template'
  autoload :Visitor, 'uniword/visitor'
  autoload :Validators, 'uniword/validators'
  autoload :Stylesets, 'uniword/stylesets'
  autoload :Infrastructure, 'uniword/infrastructure'
  autoload :Accessibility, 'uniword/accessibility'
  autoload :Assembly, 'uniword/assembly'
  autoload :Batch, 'uniword/batch'
  autoload :Metadata, 'uniword/metadata'
  autoload :Quality, 'uniword/quality'
  autoload :Schema, 'uniword/schema'

  # Namespace autoloads (Phase 2 of autoload migration)
  autoload :Configuration, 'uniword/configuration'
  autoload :Transformation, 'uniword/transformation'
  autoload :Validation, 'uniword/validation'
  autoload :Warnings, 'uniword/warnings'
  autoload :Mhtml, 'uniword/mhtml'
  autoload :Themes, 'uniword/themes'

  # Stylesets and numbering (moved to wordprocessingml/)
  autoload :StyleSet, 'uniword/styleset'

  # Content types and document properties
  autoload :ContentTypes, 'uniword/content_types'
  autoload :DocumentProperties, 'uniword/document_properties'
  autoload :Glossary, 'uniword/glossary'

  # CLI
  autoload :CLI, 'uniword/cli'

  # === Top-Level Classes (autoload) ===
  autoload :Element, 'uniword/element'

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
  autoload :LineNumbering, 'uniword/line_numbering'
  autoload :PageBorders, 'uniword/page_borders'
  autoload :ParagraphBorder, 'uniword/paragraph_border'
  autoload :Shading, 'uniword/shading'
  autoload :TabStop, 'uniword/tab_stop'

  # Infrastructure and utilities
  autoload :Builder, 'uniword/builder'
  autoload :Customxml, 'uniword/customxml'
  autoload :ElementRegistry, 'uniword/element_registry'
  autoload :FormatConverter, 'uniword/format_converter'
  autoload :LazyLoader, 'uniword/lazy_loader'
  autoload :Logger, 'uniword/logger'
  autoload :Loggable, 'uniword/loggable'
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

    # Read document from file (alias for load)
    #
    # @param path [String] File path
    # @return [Document] Loaded document
    def read(path)
      load(path)
    end

    # Parse document from string
    #
    # @param data [String] DOCX binary data
    # @return [Document] Parsed document
    def parse(data)
      DocumentFactory.from_file_data(data)
    end

    # Detect format of file
    #
    # @param path [String] File path
    # @return [Symbol] Format (:docx, :dotx, etc.)
    def detect_format(path)
      FormatDetector.detect(path)
    end

    # Get the logger instance
    #
    # @return [::Logger] The logger instance
    def logger
      Logger.logger
    end

    # Set a custom logger
    #
    # @param custom_logger [::Logger] Custom logger instance
    # @return [::Logger] The logger that was set
    def logger=(custom_logger)
      Logger.logger = custom_logger
    end

    # Check if debug logging is enabled
    #
    # @return [Boolean] true if debug level is set
    def debug?
      logger.level == ::Logger::DEBUG
    end

    # Enable debug level logging
    #
    # @return [void]
    def enable_debug_logging
      logger.level = ::Logger::DEBUG
    end

    # Disable debug level logging (set to WARN)
    #
    # @return [void]
    def disable_debug_logging
      logger.level = ::Logger::WARN
    end
  end
end
