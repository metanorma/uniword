# frozen_string_literal: true

require_relative 'transformation_rule'
require_relative 'transformation_rule_registry'
require_relative 'paragraph_transformation_rule'
require_relative 'run_transformation_rule'
require_relative 'table_transformation_rule'
require_relative 'image_transformation_rule'
require_relative 'hyperlink_transformation_rule'

module Uniword
  module Transformation
    # Transformer for converting between format-specific model representations.
    #
    # Responsibility: Transform Document models from one format's conventions
    # to another format's conventions. Single Responsibility - transformation only.
    #
    # The same Uniword model classes (Document, Paragraph, Run, Table) are used
    # for both DOCX and MHTML, but their properties and structure may differ based
    # on format conventions. The Transformer explicitly converts between these
    # conventions using declarative transformation rules.
    #
    # Architecture:
    # - Uses TransformationRuleRegistry (Open/Closed Principle)
    # - Delegates to specific rules for each element type (Single Responsibility)
    # - Rules are MECE (Mutually Exclusive, Collectively Exhaustive)
    # - Clean separation from serialization/deserialization
    #
    # @example Transform DOCX model to MHTML model
    #   transformer = Uniword::Transformation::Transformer.new
    #   mhtml_document = transformer.transform(
    #     source: docx_document,
    #     source_format: :docx,
    #     target_format: :mhtml
    #   )
    #
    # @example Named transformation methods
    #   mhtml_doc = transformer.docx_to_mhtml(docx_doc)
    #   docx_doc = transformer.mhtml_to_docx(mhtml_doc)
    class Transformer
      # Initialize transformer with transformation rules
      def initialize
        @rule_registry = TransformationRuleRegistry.new
        register_default_rules
      end

      # Transform a document from one format to another
      #
      # Explicitly declares source and target formats - no automatic detection.
      #
      # @param source [Document] Source document model
      # @param source_format [Symbol] Source format (:docx or :mhtml)
      # @param target_format [Symbol] Target format (:docx or :mhtml)
      # @return [Document] Transformed document model
      # @raise [ArgumentError] if parameters are invalid
      #
      # @example Explicit transformation
      #   target_doc = transformer.transform(
      #     source: source_doc,
      #     source_format: :docx,
      #     target_format: :mhtml
      #   )
      def transform(source:, source_format:, target_format:)
        validate_transformation(source, source_format, target_format)

        # Create new target document
        target = Document.new

        # Transform document-level metadata
        transform_metadata(source, target, source_format, target_format)

        # Transform body elements (paragraphs and tables)
        transform_body_elements(source, target, source_format, target_format)

        target
      end

      # Transform DOCX model to MHTML model
      #
      # Explicitly named method - clear intent, no magic.
      #
      # @param docx_document [Document] DOCX document model
      # @return [Document] MHTML document model
      #
      # @example Transform DOCX to MHTML
      #   mhtml_doc = transformer.docx_to_mhtml(docx_doc)
      def docx_to_mhtml(docx_document)
        transform(
          source: docx_document,
          source_format: :docx,
          target_format: :mhtml
        )
      end

      # Transform MHTML model to DOCX model
      #
      # Explicitly named method - clear intent, no magic.
      #
      # @param mhtml_document [Document] MHTML document model
      # @return [Document] DOCX document model
      #
      # @example Transform MHTML to DOCX
      #   docx_doc = transformer.mhtml_to_docx(mhtml_doc)
      def mhtml_to_docx(mhtml_document)
        transform(
          source: mhtml_document,
          source_format: :mhtml,
          target_format: :docx
        )
      end

      # Register a custom transformation rule
      #
      # Allows extension without modification (Open/Closed Principle)
      #
      # @param rule [TransformationRule] The rule to register
      # @return [self] Returns self for method chaining
      #
      # @example Register custom rule
      #   transformer.register_rule(CustomTransformationRule.new(
      #     source_format: :docx,
      #     target_format: :mhtml
      #   ))
      def register_rule(rule)
        @rule_registry.register(rule)
        self
      end

      private

      # Transform body elements (paragraphs and tables)
      #
      # @param source [Document] Source document
      # @param target [Document] Target document
      # @param source_format [Symbol] Source format
      # @param target_format [Symbol] Target format
      def transform_body_elements(source, target, source_format, target_format)
        # Transform elements in order they appear
        source.body.elements.each do |element|
          transformed = transform_element(
            element: element,
            source_format: source_format,
            target_format: target_format
          )

          # Add transformed element to target
          # Handle both single elements and arrays (for 1-to-many transformations)
          Array(transformed).each { |e| target.add_element(e) }
        end
      end

      # Transform a single element
      #
      # Finds appropriate transformation rule and applies it.
      #
      # @param element [Element] Source element
      # @param source_format [Symbol] Source format
      # @param target_format [Symbol] Target format
      # @return [Element, Array<Element>] Transformed element(s)
      def transform_element(element:, source_format:, target_format:)
        # Find applicable transformation rule
        rule = @rule_registry.find_rule(
          element_type: element.class,
          source_format: source_format,
          target_format: target_format
        )

        # Apply transformation
        rule.transform(element)
      end

      # Transform document-level metadata
      #
      # Copies styles, theme, numbering configuration with format adaptation
      #
      # @param source [Document] Source document
      # @param target [Document] Target document
      # @param source_format [Symbol] Source format
      # @param target_format [Symbol] Target format
      def transform_metadata(source, target, source_format, target_format)
        # Copy styles configuration
        if source.styles_configuration
          target.styles_configuration = source.styles_configuration.dup
        end

        # Copy numbering configuration
        if source.numbering_configuration
          target.numbering_configuration = source.numbering_configuration.dup
        end

        # Theme is DOCX-specific, copy only if target is DOCX
        if source.theme && target_format == :docx
          target.theme = source.theme.dup
        end

        # Copy sections
        if source.sections
          target.sections = source.sections.map(&:dup)
        end

        # Copy bookmarks
        if source.bookmarks
          target.bookmarks = source.bookmarks.dup
        end
      end

      # Register default transformation rules
      #
      # Creates rules for all standard element types
      def register_default_rules
        # Register Paragraph transformation (bidirectional)
        @rule_registry.register(
          ParagraphTransformationRule.new(
            source_format: :docx,
            target_format: :mhtml
          )
        )
        @rule_registry.register(
          ParagraphTransformationRule.new(
            source_format: :mhtml,
            target_format: :docx
          )
        )

        # Register Run transformation (bidirectional)
        @rule_registry.register(
          RunTransformationRule.new(
            source_format: :docx,
            target_format: :mhtml
          )
        )
        @rule_registry.register(
          RunTransformationRule.new(
            source_format: :mhtml,
            target_format: :docx
          )
        )

        # Register Table transformation (bidirectional)
        @rule_registry.register(
          TableTransformationRule.new(
            source_format: :docx,
            target_format: :mhtml
          )
        )
        @rule_registry.register(
          TableTransformationRule.new(
            source_format: :mhtml,
            target_format: :docx
          )
        )

        # Register Image transformation (bidirectional)
        @rule_registry.register(
          ImageTransformationRule.new(
            source_format: :docx,
            target_format: :mhtml
          )
        )
        @rule_registry.register(
          ImageTransformationRule.new(
            source_format: :mhtml,
            target_format: :docx
          )
        )

        # Register Hyperlink transformation (bidirectional)
        @rule_registry.register(
          HyperlinkTransformationRule.new(
            source_format: :docx,
            target_format: :mhtml
          )
        )
        @rule_registry.register(
          HyperlinkTransformationRule.new(
            source_format: :mhtml,
            target_format: :docx
          )
        )
      end

      # Validate transformation parameters
      #
      # @param source [Object] Source object to validate
      # @param source_format [Symbol] Source format
      # @param target_format [Symbol] Target format
      # @raise [ArgumentError] if parameters are invalid
      def validate_transformation(source, source_format, target_format)
        raise ArgumentError, 'Source must be a Document' unless source.is_a?(Document)

        unless [:docx, :mhtml].include?(source_format)
          raise ArgumentError,
                "Source format must be :docx or :mhtml, got #{source_format.inspect}"
        end

        unless [:docx, :mhtml].include?(target_format)
          raise ArgumentError,
                "Target format must be :docx or :mhtml, got #{target_format.inspect}"
        end
      end
    end
  end
end