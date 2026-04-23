# frozen_string_literal: true

require "lutaml/model"

require_relative "document_root/feature_facade"

module Uniword
  module Wordprocessingml
    # Root element of a WordprocessingML document
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:document>
    class DocumentRoot < Lutaml::Model::Serializable
      include FeatureFacade

      attribute :mc_ignorable, Uniword::Ooxml::Types::McIgnorable
      attribute :body, Body, default: -> { Body.new }

      xml do
        element "document"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        namespace_scope [
          { namespace: Uniword::Ooxml::Namespaces::WordprocessingCanvas, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::ChartEx, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::ChartEx1, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::ChartEx2, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::ChartEx3, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::ChartEx4, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::ChartEx5, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::ChartEx6, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::ChartEx7, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::ChartEx8, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::MarkupCompatibility, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::InkDrawing, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Model3D, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Office, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::OfficeExtensionList, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Relationships, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::MathML, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Vml, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Word2010Drawing, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::WordProcessingDrawing, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::VmlWord, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Word2010, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Word2012, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Word2018Cex, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Word2016Cid, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Word2018, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Word2023Du, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Word2020SdtDataHash, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Word2024SdtFormatLock, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::Word2015Symex, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::WordprocessingGroup, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::WordprocessingInk, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::WordNumberingEquations, declare: :always },
          { namespace: Uniword::Ooxml::Namespaces::WordprocessingShape, declare: :always }
        ]

        map_attribute "Ignorable", to: :mc_ignorable, render_nil: false

        map_element "body", to: :body, render_default: true
      end

      # Override to_xml to sync body element_order before serialization.
      # lutaml-model's compiled serializer may bypass Body#to_xml when
      # serializing Body as a child element, so we sync here at the
      # DocumentRoot level to ensure programmatically added paragraphs
      # and tables are included.
      def to_xml(options = {})
        body&.sync_element_order_for_serialization
        super
      end

      # Additional attributes for DOCX metadata (not part of document.xml)
      # These are stored in separate files within the DOCX package
      attr_accessor :theme, :raw_html, :revisions, :comments
      # Headers and footers (stored as hash: type => Header/Footer)
      # Single-section only. For multi-section, use header_footer_parts.
      attr_accessor :headers, :footers
      # Multi-section headers/footers (ordered array):
      # [{r_id: "rIdH1", target: "header1.xml", rel_type: "...",
      #   content_type: "...", content: Header|Footer}]
      attr_accessor :header_footer_parts
      # Footnotes and endnotes (separate XML parts in DOCX package)
      attr_accessor :footnotes, :endnotes
      # Image parts to embed in the DOCX package
      # Hash: r_id => { path: String, data: String, content_type: String, target: String }
      attr_accessor :image_parts
      # Chart parts to embed in the DOCX package
      # Hash: r_id => { xml: String, target: String }
      attr_accessor :chart_parts
      # Bibliography sources for sources.xml
      attr_accessor :bibliography_sources
      # Round-trip parts (copied from DocxPackage during load)
      attr_accessor :settings, :font_table, :web_settings, :document_rels, :theme_rels,
                    :package_rels, :content_types, :custom_properties, :custom_xml_items

      # Writers for properties that have lazy-initialized getters
      # (removing from attr_accessor to avoid shadowing custom getters)
      attr_writer :app_properties, :core_properties, :bookmarks

      # Get app_properties (lazy initialization)
      #
      # @return [Uniword::Ooxml::AppProperties] The app properties object
      def app_properties
        @app_properties ||= Uniword::Ooxml::AppProperties.new
      end

      # Accessor for numbering_configuration (lazy init for builder API)
      def numbering_configuration
        @numbering_configuration ||= NumberingConfiguration.new
      end

      # Setter for numbering_configuration
      attr_writer :numbering_configuration

      # Whether numbering_configuration was explicitly loaded from source
      # (vs lazily created for builder API)
      def numbering_configuration_loaded?
        !!@numbering_configuration
      end

      # Get core_properties (lazy initialization)
      #
      # @return [Uniword::Ooxml::CoreProperties] The core properties object
      def core_properties
        @core_properties ||= Uniword::Ooxml::CoreProperties.new
      end

      # Get document title (delegates to core_properties)
      #
      # @return [String, nil] The document title
      def title
        core_properties.title
      end

      # Set document title (delegates to core_properties)
      #
      # @param value [String] The document title
      def title=(value)
        core_properties.title = value
      end

      # Lazy initialization for styles_configuration
      def styles_configuration
        @styles_configuration ||= StylesConfiguration.new
      end

      # Setter for styles_configuration
      attr_writer :styles_configuration

      # Save document to file
      #
      # @param path [String] Output file path
      # @param format [Symbol] Format (:docx, :mhtml, :auto)
      def save(path, format: :auto, profile: nil)
        writer = DocumentWriter.new(self)
        writer.save(path, format: format, profile: profile)
      end

      # Save document to DOCX file using DocxPackage
      #
      # @param path [String] Output file path
      # @param profile [Docx::Profile, nil] Profile for reconciliation
      def to_file(path, profile: nil)
        Docx::Package.to_file(self, path, profile: profile)
      end

      # Get all paragraph text
      #
      # @return [String] Combined text from all paragraphs
      def text
        return "" unless body&.paragraphs

        body.paragraphs.map(&:text).join("\n")
      end

      # Get all paragraphs (convenience accessor)
      #
      # @return [Array<Paragraph>] All paragraphs in document
      def paragraphs
        body&.paragraphs || []
      end

      # Get all tables (convenience accessor)
      #
      # @return [Array<Table>] All tables in document
      def tables
        body&.tables || []
      end

      # Get all drawings (image references) from the document.
      # Walks all paragraphs and collects Drawing elements from runs.
      #
      # @return [Array<Drawing>] All drawing elements in document
      def images
        return [] unless body&.paragraphs

        body.paragraphs.flat_map do |para|
          (para.runs || []).flat_map(&:drawings)
        end.compact
      end

      # Check if document structure is valid.
      # Runs structural checks via Validation::StructuralValidator.
      # Use the verify CLI command for full OPC + XSD + semantic validation.
      #
      # @return [Boolean] true if document has valid structure
      def valid?
        Validation::StructuralValidator.new(self).valid?
      end

      # Get structural validation errors.
      #
      # @return [Array<String>] Error messages
      def validation_errors
        Validation::StructuralValidator.new(self).errors
      end

      # Get structural validation warnings.
      #
      # @return [Array<String>] Warning messages
      def validation_warnings
        Validation::StructuralValidator.new(self).warnings
      end

      # Get bookmarks from document paragraphs
      #
      # @return [Hash{String => Object}] Map of bookmark names to bookmark data
      def bookmarks
        result = {}
        return result unless body&.paragraphs

        body.paragraphs.each do |para|
          para.bookmark_starts&.each do |bs|
            result[bs.name.to_s] = bs if bs.name
          end
        end
        result
      end

      # Apply theme to document
      #
      # Applies a Uniword theme by name, updating doc defaults and
      # built-in heading/hyperlink styles to reference the theme.
      #
      # @param name [String, Symbol] Theme slug (e.g., 'meridian', 'corporate')
      # @param options [Hash] optional overrides
      # @option options [Hash] :colors override specific color keys
      # @option options [String] :major_font override major font
      # @option options [String] :minor_font override minor font
      # @return [self] For method chaining
      def apply_theme(name, **options)
        friendly = Themes::Theme.load(name.to_s)

        options[:colors]&.each do |key, value|
          friendly.color_scheme[key.to_s] = value
        end
        friendly.font_scheme.major_font = options[:major_font] if options[:major_font]
        friendly.font_scheme.minor_font = options[:minor_font] if options[:minor_font]

        word_theme = Themes::ThemeTransformation.new.to_word(friendly)
        Themes::ThemeApplicator.new.apply(word_theme, self)
        self
      end

      # Apply theme from .thmx file
      #
      # @param path [String] Path to .thmx file
      # @param variant [String, Integer, nil] Optional variant
      # @return [self] For method chaining
      def apply_theme_file(path, variant: nil)
        loader = Themes::ThemeLoader.new
        self.theme = if variant
                       loader.load_with_variant(path, variant)
                     else
                       loader.load(path)
                     end
        self
      end

      # Apply StyleSet to document
      #
      # @param name [String, Symbol] StyleSet slug (e.g., 'signature', 'heritage')
      # @param strategy [Symbol] Application strategy (:keep_existing, :replace, :rename)
      # @return [self] For method chaining
      def apply_styleset(name, strategy: :keep_existing)
        styleset = Uniword::Stylesets::YamlStyleSetLoader.load_bundled(name.to_s)
        styleset.apply_to(self, strategy: strategy)
        self
      end

      # Auto-transition from MS theme to Uniword equivalent
      #
      # Detects the MS theme in the document's embedded theme and replaces
      # it with the corresponding Uniword theme (font-substituted, renamed).
      #
      # @return [Hash, nil] { uniword_slug:, ms_name: } or nil if no match
      #
      # @example
      #   result = doc.auto_transition_theme
      #   puts "Transitioned from #{result[:ms_name]} to #{result[:uniword_slug]}"
      def auto_transition_theme
        Resource::ThemeTransition.auto_transition!(self)
      end

      # Apply theme from another document
      #
      # @param source_path [String] Path to source .docx file
      # @return [self] For method chaining
      def apply_theme_from(source_path)
        source_doc = Uniword.load(source_path)
        self.theme = source_doc.theme.dup if source_doc.theme
        self
      end

      # Apply styles from another document
      #
      # @param source_path [String] Path to source .docx file
      # @param strategy [Symbol] Conflict resolution strategy
      # @return [self] For method chaining
      def apply_styles_from(source_path, strategy: :keep_existing)
        source_doc = Uniword.load(source_path)
        styles_configuration.merge(source_doc.styles_configuration, conflict_resolution: strategy)
        self
      end

      # Apply both theme and styles from a template document
      #
      # @param template_path [String] Path to template .docx file
      # @param strategy [Symbol] Conflict resolution strategy for styles
      # @return [self] For method chaining
      def apply_template(template_path, strategy: :keep_existing)
        template_doc = Uniword.load(template_path)
        self.theme = template_doc.theme.dup if template_doc.theme
        styles_configuration.merge(template_doc.styles_configuration, conflict_resolution: strategy)
        self
      end

      # Custom inspect for readable output
      #
      # @return [String] Human-readable representation
      def inspect
        "#<#{self.class} @body=...>"
      end

      # Convert OOXML document to HTML document
      #
      # @return [String] HTML document content
      def to_html_document
        Uniword::Transformation::OoxmlToHtmlConverter.document_to_html(self)
      end
    end
  end
end
