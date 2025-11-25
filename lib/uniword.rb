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

# Uniword is a comprehensive Ruby library for reading and writing Microsoft Word
# documents in both DOCX (Word 2007+) and MHTML (Word 2003+) formats.
#
# @example Create a simple document
#   doc = Uniword::Document.new
#   para = Uniword::Paragraph.new
#   para.add_text("Hello World", bold: true)
#   doc.add_element(para)
#   doc.save('output.docx')
#
# @example Read an existing document
#   doc = Uniword::DocumentFactory.from_file('input.docx')
#   puts doc.text
#   doc.paragraphs.each { |p| puts p.text }
#
# @example Convert between formats
#   doc = Uniword::DocumentFactory.from_file('input.docx')
#   doc.save('output.doc')  # Auto-detects MHTML format from extension
#
# @see Document Main document class
# @see DocumentFactory Factory for reading documents
# @see Builder Fluent interface for document creation
module Uniword
  # Autoload core classes
  autoload :Document, 'uniword/document'
  autoload :DocumentFactory, 'uniword/document_factory'
  autoload :DocumentWriter, 'uniword/document_writer'
  autoload :FormatDetector, 'uniword/format_detector'
  # Element is eagerly loaded below, not autoloaded
  autoload :ElementRegistry, 'uniword/element_registry'
  autoload :Body, 'uniword/body'
  autoload :Paragraph, 'uniword/paragraph'
  autoload :Run, 'uniword/run'
  autoload :TextElement, 'uniword/text_element'
  autoload :Image, 'uniword/image'
  autoload :Chart, 'uniword/chart'
  autoload :Table, 'uniword/table'
  autoload :UnknownElement, 'uniword/unknown_element'
  autoload :TableRow, 'uniword/table_row'
  autoload :TableCell, 'uniword/table_cell'

  # Autoload math equation classes
  autoload :MathEquation, 'uniword/math_equation'

  # Autoload math module
  module Math
    autoload :PlurimathAdapter, 'uniword/math/plurimath_adapter'
  end

  # Autoload comment classes
  autoload :Comment, 'uniword/comment'
  autoload :CommentRange, 'uniword/comment_range'
  autoload :CommentsPart, 'uniword/comments_part'

  # Autoload footnotes and endnotes
  autoload :Footnote, 'uniword/footnote'
  autoload :Endnote, 'uniword/endnote'
  autoload :Bookmark, 'uniword/bookmark'

  # Autoload track changes classes
  autoload :Revision, 'uniword/revision'
  autoload :TrackedChanges, 'uniword/tracked_changes'

  # Autoload developer experience classes
  autoload :Builder, 'uniword/builder'
  autoload :CLI, 'uniword/cli'
  autoload :Logger, 'uniword/logger'

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

  # Autoload numbering classes
  autoload :NumberingLevel, 'uniword/numbering_level'
  autoload :NumberingDefinition, 'uniword/numbering_definition'
  autoload :NumberingInstance, 'uniword/numbering_instance'
  autoload :NumberingConfiguration, 'uniword/numbering_configuration'

  # Autoload styles
  autoload :StylesConfiguration, 'uniword/styles_configuration'
  autoload :Style, 'uniword/style'
  autoload :ParagraphStyle, 'uniword/paragraph_style'
  autoload :CharacterStyle, 'uniword/character_style'
  # Autoload styles DSL (v6.0)
  module Styles
    autoload :StyleLibrary, 'uniword/styles/style_library'
    autoload :StyleBuilder, 'uniword/styles/style_builder'
    autoload :StyleDefinition, 'uniword/styles/style_definition'
    autoload :ParagraphStyleDefinition, 'uniword/styles/paragraph_style_definition'
    autoload :CharacterStyleDefinition, 'uniword/styles/character_style_definition'
    autoload :ListStyleDefinition, 'uniword/styles/list_style_definition'
    autoload :TableStyleDefinition, 'uniword/styles/table_style_definition'
    autoload :SemanticStyle, 'uniword/styles/semantic_style'

    module DSL
      autoload :ListContext, 'uniword/styles/dsl/list_context'
      autoload :TableContext, 'uniword/styles/dsl/table_context'
      autoload :ParagraphContext, 'uniword/styles/dsl/paragraph_context'
    end
  end


  # Autoload themes
  autoload :Theme, 'uniword/theme'
  autoload :ColorScheme, 'uniword/color_scheme'
  autoload :FontScheme, 'uniword/font_scheme'

  # Autoload stylesets
  autoload :StyleSet, 'uniword/styleset'

  # Autoload theme infrastructure
  module Themes
    autoload :ThemeLoader, 'uniword/theme/theme_loader'
    autoload :ThemePackageReader, 'uniword/theme/theme_package_reader'
    autoload :ThemeXmlParser, 'uniword/theme/theme_xml_parser'
    autoload :ThemeApplicator, 'uniword/theme/theme_applicator'
    autoload :ThemeVariant, 'uniword/theme/theme_variant'
    autoload :ThemeImporter, 'uniword/themes/theme_importer'
    autoload :YamlThemeLoader, 'uniword/themes/yaml_theme_loader'
  end

  # Autoload styleset infrastructure
  module StyleSets
    autoload :StyleSetLoader, 'uniword/stylesets/styleset_loader'
    autoload :StyleSetPackageReader, 'uniword/stylesets/styleset_package_reader'
    autoload :StyleSetXmlParser, 'uniword/stylesets/styleset_xml_parser'
  end

  # Autoload sections and headers/footers
  autoload :Section, 'uniword/section'
  autoload :SectionProperties, 'uniword/section_properties'
  autoload :Header, 'uniword/header'
  autoload :Footer, 'uniword/footer'

  # Autoload fields and text boxes
  autoload :Field, 'uniword/field'
  autoload :TextBox, 'uniword/text_box'

  # Autoload new v1.1 features
  autoload :Hyperlink, 'uniword/hyperlink'
  autoload :PageBorders, 'uniword/page_borders'
  autoload :ParagraphBorders, 'uniword/paragraph_border'
  autoload :ParagraphBorderSide, 'uniword/paragraph_border'
  autoload :TabStop, 'uniword/tab_stop'
  autoload :Shading, 'uniword/shading'
  autoload :ColumnConfiguration, 'uniword/column_configuration'
  autoload :Column, 'uniword/column_configuration'
  autoload :LineNumbering, 'uniword/line_numbering'
  autoload :TextFrame, 'uniword/text_frame'
  autoload :HtmlImporter, 'uniword/html_importer'

  # Autoload properties classes
  module Properties
    autoload :ParagraphProperties, 'uniword/properties/paragraph_properties'
    autoload :RunProperties, 'uniword/properties/run_properties'
    autoload :TableProperties, 'uniword/properties/table_properties'
  end

  # Autoload table-related classes
  autoload :TableBorder, 'uniword/table_border'

  # Autoload format handlers
  module Formats
    autoload :BaseHandler, 'uniword/formats/base_handler'
    autoload :DocxHandler, 'uniword/formats/docx_handler'
    autoload :MhtmlHandler, 'uniword/formats/mhtml_handler'
    autoload :FormatHandlerRegistry, 'uniword/formats/format_handler_registry'
  end

  # Autoload validators
  module Validators
    autoload :ElementValidator, 'uniword/validators/element_validator'
    autoload :ParagraphValidator, 'uniword/validators/paragraph_validator'
    autoload :TableValidator, 'uniword/validators/table_validator'
  end

  # Autoload visitors
  module Visitor
    autoload :BaseVisitor, 'uniword/visitor/base_visitor'
    autoload :TextExtractor, 'uniword/visitor/text_extractor'
  end

  # Autoload infrastructure
  module Infrastructure
    autoload :ZipExtractor, 'uniword/infrastructure/zip_extractor'
    autoload :ZipPackager, 'uniword/infrastructure/zip_packager'
    autoload :MimeParser, 'uniword/infrastructure/mime_parser'
    autoload :MimePackager, 'uniword/infrastructure/mime_packager'
  end

  # Autoload HTML serialization (OOXML uses native lutaml-model serialization via DocxPackage)
  module Serialization
    autoload :HtmlDeserializer, 'uniword/serialization/html_deserializer'
    autoload :HtmlSerializer, 'uniword/serialization/html_serializer'
  end

  # Autoload transformation
  module Transformation
    autoload :TransformationRule, 'uniword/transformation/transformation_rule'
    autoload :TransformationRuleRegistry, 'uniword/transformation/transformation_rule_registry'
    autoload :ParagraphTransformationRule, 'uniword/transformation/paragraph_transformation_rule'
    autoload :RunTransformationRule, 'uniword/transformation/run_transformation_rule'
    autoload :TableTransformationRule, 'uniword/transformation/table_transformation_rule'
    autoload :ImageTransformationRule, 'uniword/transformation/image_transformation_rule'
    autoload :HyperlinkTransformationRule, 'uniword/transformation/hyperlink_transformation_rule'
    autoload :Transformer, 'uniword/transformation/transformer'
  end

  # Autoload format converter
  autoload :FormatConverter, 'uniword/format_converter'

  # Autoload OOXML support
  module Ooxml
    autoload :CoreProperties, 'uniword/ooxml/core_properties'
    autoload :AppProperties, 'uniword/ooxml/app_properties'
    autoload :ContentTypes, 'uniword/ooxml/content_types'
    autoload :Relationships, 'uniword/ooxml/relationships'
    autoload :DocxPackager, 'uniword/ooxml/docx_packager'

    # Autoload OOXML schema (v2.0.0)
    module Schema
      autoload :OoxmlSchema, 'uniword/ooxml/schema/ooxml_schema'
      autoload :ElementDefinition, 'uniword/ooxml/schema/element_definition'
      autoload :ChildDefinition, 'uniword/ooxml/schema/child_definition'
      autoload :AttributeDefinition, 'uniword/ooxml/schema/attribute_definition'
      autoload :ElementSerializer, 'uniword/ooxml/schema/element_serializer'
    end
  end

  # Autoload configuration module
  module Configuration
    autoload :ConfigurationLoader, 'uniword/configuration/configuration_loader'
    autoload :ConfigurationError, 'uniword/configuration/configuration_loader'
  end

  # Autoload quality checking module
  module Quality
    autoload :QualityRule, 'uniword/quality/quality_rule'
    autoload :QualityViolation, 'uniword/quality/quality_rule'
    autoload :QualityReport, 'uniword/quality/quality_report'
    autoload :DocumentChecker, 'uniword/quality/document_checker'
    autoload :QualityCheckError, 'uniword/quality/document_checker'
    autoload :HeadingHierarchyRule, 'uniword/quality/rules/heading_hierarchy_rule'
    autoload :TableHeaderRule, 'uniword/quality/rules/table_header_rule'
    autoload :ParagraphLengthRule, 'uniword/quality/rules/paragraph_length_rule'
    autoload :ImageAltTextRule, 'uniword/quality/rules/image_alt_text_rule'
    autoload :LinkValidationRule, 'uniword/quality/rules/link_validation_rule'
    autoload :StyleConsistencyRule, 'uniword/quality/rules/style_consistency_rule'
  end

  # Autoload batch processing module
  module Batch
    autoload :ProcessingStage, 'uniword/batch/processing_stage'
    autoload :BatchResult, 'uniword/batch/batch_result'
    autoload :DocumentProcessor, 'uniword/batch/document_processor'
    autoload :NormalizeStylesStage, 'uniword/batch/stages/normalize_styles_stage'
    autoload :UpdateMetadataStage, 'uniword/batch/stages/update_metadata_stage'
    autoload :ValidateLinksStage, 'uniword/batch/stages/validate_links_stage'
    autoload :ConvertFormatStage, 'uniword/batch/stages/convert_format_stage'
    autoload :CompressImagesStage, 'uniword/batch/stages/compress_images_stage'
    autoload :QualityCheckStage, 'uniword/batch/stages/quality_check_stage'
  end

  # Autoload validation module (v5.0)
  module Validation
    autoload :LinkValidator, 'uniword/validation/link_validator'
    autoload :ValidationResult, 'uniword/validation/validation_result'
    autoload :ValidationReport, 'uniword/validation/validation_report'
    autoload :LinkChecker, 'uniword/validation/link_checker'

    module Checkers
      autoload :ExternalLinkChecker, 'uniword/validation/checkers/external_link_checker'
      autoload :InternalLinkChecker, 'uniword/validation/checkers/internal_link_checker'
      autoload :FileReferenceChecker, 'uniword/validation/checkers/file_reference_checker'
      autoload :FootnoteReferenceChecker, 'uniword/validation/checkers/footnote_reference_checker'
    end
  end

  # Autoload accessibility module (v6.0)
  module Accessibility
    autoload :AccessibilityChecker, 'uniword/accessibility/accessibility_checker'
    autoload :AccessibilityRule, 'uniword/accessibility/accessibility_rule'
    autoload :AccessibilityProfile, 'uniword/accessibility/accessibility_profile'
    autoload :AccessibilityReport, 'uniword/accessibility/accessibility_report'
    autoload :AccessibilityViolation, 'uniword/accessibility/accessibility_violation'

    module Rules
      autoload :ImageAltTextRule, 'uniword/accessibility/rules/image_alt_text_rule'
      autoload :HeadingStructureRule, 'uniword/accessibility/rules/heading_structure_rule'
      autoload :TableHeadersRule, 'uniword/accessibility/rules/table_headers_rule'
      autoload :ListStructureRule, 'uniword/accessibility/rules/list_structure_rule'
      autoload :ReadingOrderRule, 'uniword/accessibility/rules/reading_order_rule'
      autoload :ColorUsageRule, 'uniword/accessibility/rules/color_usage_rule'
      autoload :ContrastRatioRule, 'uniword/accessibility/rules/contrast_ratio_rule'
      autoload :DocumentTitleRule, 'uniword/accessibility/rules/document_title_rule'
      autoload :DescriptiveHeadingsRule, 'uniword/accessibility/rules/descriptive_headings_rule'
      autoload :LanguageSpecificationRule, 'uniword/accessibility/rules/language_specification_rule'
    end
  end

  # Autoload warnings module (v6.0 Phase 5)
  module Warnings
    autoload :Warning, 'uniword/warnings/warning'
    autoload :WarningCollector, 'uniword/warnings/warning_collector'
    autoload :WarningReport, 'uniword/warnings/warning_report'
  end

  # Autoload template system (v6.0 Phase 4)
  module Template
    autoload :Template, 'uniword/template/template'
    autoload :TemplateParser, 'uniword/template/template_parser'
    autoload :TemplateRenderer, 'uniword/template/template_renderer'
    autoload :TemplateMarker, 'uniword/template/template_marker'
    autoload :TemplateContext, 'uniword/template/template_context'
    autoload :VariableResolver, 'uniword/template/variable_resolver'
    autoload :TemplateValidator, 'uniword/template/template_validator'

    module Helpers
      autoload :LoopHelper, 'uniword/template/helpers/loop_helper'
      autoload :ConditionalHelper, 'uniword/template/helpers/conditional_helper'
      autoload :VariableHelper, 'uniword/template/helpers/variable_helper'
      autoload :FilterHelper, 'uniword/template/helpers/filter_helper'
    end
  end
end

# Eagerly load element classes that need validators
require_relative 'uniword/element'
require_relative 'uniword/paragraph'
require_relative 'uniword/table'

# Eagerly load validators for registration
# Load them after element classes are loaded
require_relative 'uniword/validators/element_validator'
require_relative 'uniword/validators/paragraph_validator'
require_relative 'uniword/validators/table_validator'

# Explicitly register validators after all classes are loaded
# This ensures registration happens with actual class objects, not autoload stubs
Uniword::Validators::ElementValidator.register(
  Uniword::Paragraph,
  Uniword::Validators::ParagraphValidator
)
Uniword::Validators::ElementValidator.register(
  Uniword::Table,
  Uniword::Validators::TableValidator
)

# Eagerly load format handlers to trigger self-registration
require_relative 'uniword/formats/docx_handler'
require_relative 'uniword/formats/mhtml_handler'

# Module-level convenience methods
module Uniword
  # Import HTML into a Uniword document
  #
  # @param html [String] HTML content
  # @param options [Hash] Import options
  # @return [Document] The generated document
  def self.from_html(html, **options)
    HtmlImporter.new(html, **options).to_document
  end

  # Convert HTML file to Word DOC (MHTML) format
  # Provides html2doc compatibility
  #
  # @param html_file [String] Path to HTML file
  # @param output [String] Path to output DOC file
  # @param options [Hash] Import options
  # @return [void]
  def self.html_to_doc(html_file, output, **options)
    html = File.read(html_file)
    doc = from_html(html, **options)
    doc.save(output, format: :mhtml)
  end

  # Convert HTML file to Word DOCX format
  #
  # @param html_file [String] Path to HTML file
  # @param output [String] Path to output DOCX file
  # @param options [Hash] Import options
  # @return [void]
  def self.html_to_docx(html_file, output, **options)
    html = File.read(html_file)
    doc = from_html(html, **options)
    doc.save(output, format: :docx)
  end

  # Convert HTML string to Word DOC (MHTML) format
  #
  # @param html [String] HTML content
  # @param output [String] Path to output DOC file
  # @param options [Hash] Import options
  # @return [void]
  def self.html_string_to_doc(html, output, **options)
    doc = from_html(html, **options)
    doc.save(output, format: :mhtml)
  end

  # Convert HTML string to Word DOCX format
  #
  # @param html [String] HTML content
  # @param output [String] Path to output DOCX file
  # @param options [Hash] Import options
  # @return [void]
  def self.html_string_to_docx(html, output, **options)
    doc = from_html(html, **options)
    doc.save(output, format: :docx)
  end
end
