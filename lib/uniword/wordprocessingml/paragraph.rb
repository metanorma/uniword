# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Paragraph - block-level text element
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:p>
    class Paragraph < Lutaml::Model::Serializable
      attribute :properties, Uniword::Ooxml::WordProcessingML::ParagraphProperties
      attribute :runs, Run, collection: true, default: -> { [] }
      attribute :hyperlinks, Hyperlink, collection: true, default: -> { [] }
      attribute :bookmark_starts, BookmarkStart, collection: true, default: -> { [] }
      attribute :bookmark_ends, BookmarkEnd, collection: true, default: -> { [] }
      attribute :field_chars, FieldChar, collection: true, default: -> { [] }
      attribute :instr_text, InstrText, collection: true, default: -> { [] }
      attribute :comment_range_starts, CommentRangeStart, collection: true, default: -> { [] }
      attribute :comment_range_ends, CommentRangeEnd, collection: true, default: -> { [] }
      attribute :comment_references, CommentReference, collection: true, default: -> { [] }
      attribute :alternate_content, AlternateContent, default: nil
      attribute :sdts, StructuredDocumentTag, collection: true, default: -> { [] }
      attribute :o_math_paras, Uniword::Math::OMathPara, collection: true, default: -> { [] }

      # Pattern 0: Revision tracking attributes (rsid)
      attribute :rsid_r, :string          # Revision ID for paragraph creation
      attribute :rsid_r_default, :string  # Default revision ID
      attribute :rsid_p, :string          # Revision ID for properties

      xml do
        element 'p'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        # Revision tracking attributes
        map_attribute 'rsidR', to: :rsid_r, render_nil: false
        map_attribute 'rsidRDefault', to: :rsid_r_default, render_nil: false
        map_attribute 'rsidP', to: :rsid_p, render_nil: false

        map_element 'pPr', to: :properties, render_nil: false
        map_element 'r', to: :runs, render_nil: false
        map_element 'hyperlink', to: :hyperlinks, render_nil: false
        map_element 'bookmarkStart', to: :bookmark_starts, render_nil: false
        map_element 'bookmarkEnd', to: :bookmark_ends, render_nil: false
        map_element 'fldChar', to: :field_chars, render_nil: false
        map_element 'instrText', to: :instr_text, render_nil: false
        map_element 'commentRangeStart', to: :comment_range_starts, render_nil: false
        map_element 'commentRangeEnd', to: :comment_range_ends, render_nil: false
        map_element 'commentReference', to: :comment_references, render_nil: false
        map_element 'AlternateContent', to: :alternate_content, render_nil: false
        map_element 'sdt', to: :sdts, render_nil: false
        map_element 'oMathPara', to: :o_math_paras,
                    namespace: Uniword::Ooxml::Namespaces::MathML,
                    render_nil: false
      end

      # Add text run to paragraph
      #
      # @param text [String] Text content
      # @param options [Hash] Formatting options
      # @return [Run] The created run
      def add_text(text, **options)
        run = Run.new
        run.text = text

        if options.any?
          run.properties ||= Uniword::Ooxml::WordProcessingML::RunProperties.new
          run.properties.bold = true if options[:bold]
          run.properties.italic = true if options[:italic]
          run.properties.underline = options[:underline] if options[:underline]
          run.properties.color = options[:color] if options[:color]
          run.properties.sz = options[:size] * 2 if options[:size]
          run.properties.font = options[:font] if options[:font]
        end

        self.runs ||= []
        runs << run
        run
      end

      # Add run to paragraph
      #
      # @param text [String, nil] Optional text content
      # @param options [Hash] Formatting options
      # @return [Run] The created run
      def add_run(text = nil, **options)
        add_text(text, **options) if text
      end

      # Get paragraph text
      #
      # @return [String] Combined text from all runs
      def text
        return '' unless runs
        runs.map { |r| r.text.to_s }.join
      end

      # Check if paragraph is empty
      #
      # @return [Boolean] true if no runs or all runs empty
      def empty?
        !runs || runs.empty? || runs.all? { |r| r.text.to_s.empty? }
      end

      # Set paragraph alignment (fluent interface)
      #
      # @param alignment [String, Symbol] Alignment value (left, center, right, justify)
      # @return [self] For method chaining
      def align(alignment)
        self.properties ||= Uniword::Ooxml::WordProcessingML::ParagraphProperties.new
        properties.alignment = alignment.to_s
        self
      end

      # Set paragraph style
      #
      # @param style_name [String] Style name or ID
      # @return [self] For method chaining
      def set_style(style_name)
        self.properties ||= Uniword::Ooxml::WordProcessingML::ParagraphProperties.new
        properties.style = style_name
        self
      end

      # Set paragraph numbering
      #
      # @param num_id [Integer] Numbering ID
      # @param level [Integer] Numbering level (0-based)
      # @return [self] For method chaining
      def set_numbering(num_id, level = 0)
        self.properties ||= Uniword::Ooxml::WordProcessingML::ParagraphProperties.new
        properties.num_id = num_id
        properties.ilvl = level
        self
      end

      # Set spacing before paragraph
      #
      # @param value [Integer] Spacing in twips (1/1440 inch)
      # @return [self] For method chaining
      def spacing_before(value)
        self.properties ||= Uniword::Ooxml::WordProcessingML::ParagraphProperties.new
        properties.spacing_before = value
        self
      end

      # Set spacing after paragraph
      #
      # @param value [Integer] Spacing in twips (1/1440 inch)
      # @return [self] For method chaining
      def spacing_after(value)
        self.properties ||= Uniword::Ooxml::WordProcessingML::ParagraphProperties.new
        properties.spacing_after = value
        self
      end

      # Set line spacing
      #
      # @param value [Float] Line spacing multiplier
      # @param rule [String] Line rule (auto, exact, atLeast)
      # @return [self] For method chaining
      def line_spacing(value, rule = 'auto')
        self.properties ||= Uniword::Ooxml::WordProcessingML::ParagraphProperties.new
        properties.line_spacing = value
        properties.line_rule = rule
        self
      end

      # Set left indent
      #
      # @param value [Integer] Indent in twips (1/1440 inch)
      # @return [self] For method chaining
      def indent_left(value)
        self.properties ||= Uniword::Ooxml::WordProcessingML::ParagraphProperties.new
        properties.indent_left = value
        self
      end

      # Set right indent
      #
      # @param value [Integer] Indent in twips (1/1440 inch)
      # @return [self] For method chaining
      def indent_right(value)
        self.properties ||= Uniword::Ooxml::WordProcessingML::ParagraphProperties.new
        properties.indent_right = value
        self
      end

      # Set first line indent
      #
      # @param value [Integer] Indent in twips (1/1440 inch)
      # @return [self] For method chaining
      def indent_first_line(value)
        self.properties ||= Uniword::Ooxml::WordProcessingML::ParagraphProperties.new
        properties.indent_first_line = value
        self
      end
    end
  end
end
