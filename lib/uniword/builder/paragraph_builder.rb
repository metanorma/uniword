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
    class ParagraphBuilder < BaseBuilder
      include HasBorders
      include HasShading

      def self.default_model_class
        Wordprocessingml::Paragraph
      end

      # Append a child element. Routes by type:
      # - String -> creates a Run
      # - Run -> appends to runs
      # - Hyperlink -> appends to hyperlinks
      # - TabStop -> appends to properties.tabs
      # - BookmarkStart/End -> appends to bookmarks
      # - StructuredDocumentTag -> appends to sdts
      #
      # @param element [String, Run, Hyperlink, Properties::TabStop, ...]
      # @return [self]
      def <<(element)
        case element
        when String
          @model.runs << Wordprocessingml::Run.new(text: element)
          track_element_order("r")
        when Wordprocessingml::Run
          @model.runs << element
          track_element_order("r")
        when Wordprocessingml::Hyperlink
          @model.hyperlinks << element
          track_element_order("hyperlink")
        when Properties::TabStop
          ensure_properties
          @model.properties.tabs ||= Properties::Tabs.new
          @model.properties.tabs << element
        when Wordprocessingml::BookmarkStart
          @model.bookmark_starts << element
          track_element_order("bookmarkStart")
        when Wordprocessingml::BookmarkEnd
          @model.bookmark_ends << element
          track_element_order("bookmarkEnd")
        when Wordprocessingml::StructuredDocumentTag
          @model.sdts << element
          track_element_order("sdt")
        when RunBuilder
          @model.runs << element.build
          track_element_order("r")
        else
          raise ArgumentError, "Cannot add #{element.class} to paragraph"
        end
        self
      end

      def style=(name)
        ensure_properties.style = Properties::StyleReference.new(value: name)
        self
      end

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

      def keep_next(value = true)
        ensure_properties.keep_next_wrapper =
          value ? Properties::KeepNext.new(value: true) : nil
        self
      end

      def page_break_before(value = true)
        ensure_properties.page_break_before_wrapper =
          value ? Properties::PageBreakBefore.new(value: true) : nil
        self
      end

      def contextual_spacing=(value)
        ensure_properties.contextual_spacing = value
        self
      end

      def outline_level=(value)
        ensure_properties.outline_level = value
        self
      end

      private

      def ensure_properties
        @model.properties ||= Wordprocessingml::ParagraphProperties.new
        ensure_properties_in_order
        @model.properties
      end

      def track_element_order(tag)
        @model.element_order ||= []
        ensure_properties_in_order
        @model.element_order << Lutaml::Xml::Element.new("Element", tag)
      end

      def ensure_properties_in_order
        return unless @model.element_order
        return if @model.element_order.any? { |e| e.element? && e.name == "pPr" }
        return unless @model.properties

        @model.element_order.unshift(Lutaml::Xml::Element.new("Element", "pPr"))
      end
    end
  end
end
