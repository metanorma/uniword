# frozen_string_literal: true

module Uniword
  module Builder
    # Builds and configures Paragraph objects.
    #
    # Uses << operator to append child elements with smart type routing.
    #
    # @example Create a simple paragraph
    #   para = ParagraphBuilder.new
    #   para << 'Hello World'
    #   para.build
    #
    # @example Styled paragraph with mixed content
    #   para = ParagraphBuilder.new
    #   para.style = 'Heading1'
    #   para << Builder.text('Title', bold: true, size: 24)
    #   para << Builder.hyperlink('https://example.com', 'link')
    #   para << Builder.tab_stop(position: 7200)
    #   para.build
    class ParagraphBuilder
      attr_reader :model

      def initialize(model = nil)
        @model = model || Wordprocessingml::Paragraph.new
      end

      # Wrap an existing Paragraph model for manipulation
      #
      # @param model [Wordprocessingml::Paragraph] Existing paragraph
      # @return [ParagraphBuilder]
      def self.from_model(model)
        new(model)
      end

      # Append a child element. Routes by type:
      # - String → creates a Run
      # - Run → appends to runs
      # - Hyperlink → appends to hyperlinks
      # - TabStop → appends to properties.tabs
      # - BookmarkStart/End → appends to bookmarks
      # - StructuredDocumentTag → appends to sdts
      #
      # @param element [String, Run, Hyperlink, Properties::TabStop, ...]
      # @return [self]
      def <<(element)
        case element
        when String
          @model.runs << Wordprocessingml::Run.new(text: element)
        when Wordprocessingml::Run
          @model.runs << element
        when Wordprocessingml::Hyperlink
          @model.hyperlinks << element
        when Properties::TabStop
          ensure_properties
          @model.properties.tabs ||= Properties::Tabs.new
          @model.properties.tabs << element
        when Wordprocessingml::BookmarkStart
          @model.bookmark_starts << element
        when Wordprocessingml::BookmarkEnd
          @model.bookmark_ends << element
        when Wordprocessingml::StructuredDocumentTag
          @model.sdts << element
        when RunBuilder
          @model.runs << element.build
        else
          raise ArgumentError, "Cannot add #{element.class} to paragraph"
        end
        self
      end

      # Set paragraph style
      #
      # @param name [String] Style name or ID
      # @return [self]
      def style=(name)
        ensure_properties.style = Properties::StyleReference.new(value: name)
        self
      end

      # Set paragraph alignment
      #
      # @param value [String, Symbol] :left, :center, :right, :justify
      # @return [self]
      def align=(value)
        ensure_properties.alignment = Properties::Alignment.new(value: value.to_s)
        self
      end

      # Set paragraph spacing
      #
      # @param before [Integer, nil] Spacing before in twips
      # @param after [Integer, nil] Spacing after in twips
      # @param line [Integer, nil] Line spacing in twips
      # @param rule [String, nil] Line rule ('auto', 'exact', 'atLeast')
      # @return [self]
      def spacing(before: nil, after: nil, line: nil, rule: nil)
        ensure_properties.spacing ||= Properties::Spacing.new
        props = @model.properties.spacing
        props.before = before if before
        props.after = after if after
        props.line = line if line
        props.line_rule = rule if rule
        self
      end

      # Set paragraph indentation
      #
      # @param left [Integer, nil] Left indent in twips
      # @param right [Integer, nil] Right indent in twips
      # @param first_line [Integer, nil] First line indent in twips
      # @param hanging [Integer, nil] Hanging indent in twips
      # @return [self]
      def indent(left: nil, right: nil, first_line: nil, hanging: nil)
        ensure_properties.indentation ||= Properties::Indentation.new
        ind = @model.properties.indentation
        ind.left = left if left
        ind.right = right if right
        ind.first_line = first_line if first_line
        ind.hanging = hanging if hanging
        self
      end

      # Set paragraph borders
      #
      # @param sides [Hash] Border specifications by side
      # @option sides [Hash, String] :top Border hash or color string
      # @option sides [Hash, String] :bottom Border hash or color string
      # @option sides [Hash, String] :left Border hash or color string
      # @option sides [Hash, String] :right Border hash or color string
      # @return [self]
      def borders(**sides)
        ensure_properties.borders ||= Properties::Borders.new
        sides.each do |side, value|
          border = if value.is_a?(Hash)
                     Properties::Border.new(**value)
                   else
                     Properties::Border.new(color: value, style: "single",
                                            size: 4)
                   end
          @model.properties.borders.send("#{side}=", border)
        end
        self
      end

      # Set paragraph shading
      #
      # @param fill [String] Fill color
      # @param color [String, nil] Shading color
      # @param pattern [String] Pattern (default 'clear')
      # @return [self]
      def shading(fill:, color: nil, pattern: "clear")
        ensure_properties.shading = Properties::Shading.new(
          fill: fill, color: color, pattern: pattern,
        )
        self
      end

      # Set numbering
      #
      # @param num_id [Integer] Numbering definition ID
      # @param level [Integer] Numbering level (0-based, default 0)
      # @return [self]
      def numbering(num_id, level = 0)
        props = ensure_properties
        props.num_id = num_id
        props.ilvl = level
        props.numbering_properties = Properties::NumberingProperties.new(
          num_id: Properties::NumberingId.new(value: num_id),
          ilvl: Properties::NumberingLevel.new(value: level),
        )
        self
      end

      # Set keep next
      #
      # @param value [Boolean] Keep with next paragraph (default true)
      # @return [self]
      def keep_next(value = true)
        ensure_properties.keep_next_wrapper =
          value ? Properties::KeepNext.new(value: true) : nil
        self
      end

      # Set page break before
      #
      # @param value [Boolean] Page break before (default true)
      # @return [self]
      def page_break_before(value = true)
        ensure_properties.page_break_before_wrapper =
          value ? Properties::PageBreakBefore.new(value: true) : nil
        self
      end

      # Set contextual spacing
      #
      # @param value [Boolean] Contextual spacing state
      # @return [self]
      def contextual_spacing=(value)
        ensure_properties.contextual_spacing = value
        self
      end

      # Set outline level
      #
      # @param value [String] Outline level
      # @return [self]
      def outline_level=(value)
        ensure_properties.outline_level = value
        self
      end

      # Return the underlying Paragraph model
      #
      # @return [Wordprocessingml::Paragraph]
      def build
        @model
      end

      private

      # Ensure ParagraphProperties exist on the model
      #
      # @return [Wordprocessingml::ParagraphProperties]
      def ensure_properties
        @model.properties ||= Wordprocessingml::ParagraphProperties.new
        @model.properties
      end
    end
  end
end
