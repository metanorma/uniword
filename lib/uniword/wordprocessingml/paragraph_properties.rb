# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Paragraph formatting properties
    #
    # Represents w:pPr element containing paragraph-level formatting.
    # Used in StyleSets and document paragraph elements.
    class ParagraphProperties < Lutaml::Model::Serializable
      # Pattern 0: ATTRIBUTES FIRST, then XML mappings

      # Simple element attributes (OOXML w:val attributes stored in wrapper objects)
      attribute :style, Properties::StyleReference    # w:pStyle w:val="..." (style ID reference)
      attribute :alignment, Properties::Alignment     # w:jc w:val="..." (alignment value)

      # Simple element wrapper objects
      attribute :outline_level, Properties::OutlineLevel
      attribute :numbering_properties, Properties::NumberingProperties

      # Complex spacing object
      attribute :spacing, Properties::Spacing

      # Complex indentation object
      attribute :indentation, Properties::Indentation

      # Complex borders object
      attribute :borders, Properties::Borders

      # Complex tabs object
      attribute :tabs, Properties::Tabs

      # Complex shading object
      attribute :shading, Properties::Shading

      # Run properties (for pPr/rPr)
      attribute :run_properties, RunProperties

      # Flat spacing attributes - use spacing object for XML, these for flat API
      # Note: These shadow the convenience methods below - use spacing.line/line_rule for XML
      attribute :spacing_before, :integer
      attribute :spacing_after, :integer
      attribute :line_spacing, :float # Flat attribute for simple API (supports 1.5, 2.0, etc.)
      attribute :line_rule, :string # Flat attribute for simple API

      # Flat indentation attributes (for parser compatibility)
      attribute :indent_left, :integer
      attribute :indent_right, :integer
      attribute :indent_first_line, :integer

      # Numbering
      attribute :num_id, :integer
      attribute :ilvl, :integer # Numbering level (0-8)

      # Keep together options (wrapper objects - use _wrapper suffix for internal storage)
      attribute :keep_next_wrapper, Properties::KeepNext
      attribute :keep_lines_wrapper, Properties::KeepLines
      attribute :page_break_before_wrapper, Properties::PageBreakBefore
      attribute :widow_control_wrapper, Properties::WidowControl

      # Spacing options
      attribute :contextual_spacing, Properties::ContextualSpacing
      attribute :suppress_line_numbers, :boolean, default: -> { false }

      # Bidirectional text
      attribute :bidirectional, :boolean, default: -> { false }

      # East Asian typography
      attribute :auto_space_de, Properties::AutoSpaceDE
      attribute :auto_space_dn, Properties::AutoSpaceDN

      # Right indent adjustment
      attribute :adjust_right_ind, Properties::AdjustRightInd

      # Section properties (for paragraph-level section breaks)
      attribute :section_properties, SectionProperties

      # Shading (background color)
      attribute :shading_fill, :string      # RGB hex color
      attribute :shading_color, :string     # Pattern color
      attribute :shading_type, :string      # clear, solid, etc.

      # YAML mappings for flat YAML structure (StyleSet compatibility)
      # The YAML uses flat attributes like spacing_before, spacing_after, alignment, etc.
      # which match the flat attributes defined in this class.
      yaml do
        map "style", with: { from: :yaml_style_from, to: :yaml_style_to }
        map "alignment",
            with: { from: :yaml_alignment_from, to: :yaml_alignment_to }
        map "spacing_before", to: :spacing_before
        map "spacing_after", to: :spacing_after
        map "line_spacing", to: :line_spacing
        map "line_rule", to: :line_rule
        map "keep_next",
            with: { from: :yaml_keep_next_from, to: :yaml_keep_next_to }
        map "keep_lines",
            with: { from: :yaml_keep_lines_from, to: :yaml_keep_lines_to }
        map "page_break_before",
            with: { from: :yaml_page_break_before_from,
                    to: :yaml_page_break_before_to }
        map "outline_level",
            with: { from: :yaml_outline_level_from, to: :yaml_outline_level_to }
        map "suppress_line_numbers", to: :suppress_line_numbers
        map "contextual_spacing",
            with: { from: :yaml_contextual_spacing_from,
                    to: :yaml_contextual_spacing_to }
        map "bidirectional", to: :bidirectional
        map "indent_left", to: :indent_left
        map "indent_right", to: :indent_right
        map "indent_first_line", to: :indent_first_line
        map "widow_control",
            with: { from: :yaml_widow_control_from, to: :yaml_widow_control_to }
      end

      # YAML transform methods (instance methods - called via send on an instance)
      def yaml_style_from(instance, value)
        instance.style = Properties::StyleReference.new(value: value) if value
      end

      def yaml_style_to(instance, _doc)
        instance.style&.value
      end

      def yaml_alignment_from(instance, value)
        instance.alignment = Properties::Alignment.new(value: value) if value
      end

      def yaml_alignment_to(instance, _doc)
        instance.alignment&.value
      end

      def yaml_keep_next_from(instance, value)
        instance.keep_next_wrapper = Properties::KeepNext.new(value: value) unless value.nil?
      end

      def yaml_keep_next_to(instance, _doc)
        instance.keep_next_wrapper&.value
      end

      def yaml_keep_lines_from(instance, value)
        instance.keep_lines_wrapper = Properties::KeepLines.new(value: value) unless value.nil?
      end

      def yaml_keep_lines_to(instance, _doc)
        instance.keep_lines_wrapper&.value
      end

      def yaml_outline_level_from(instance, value)
        instance.outline_level = Properties::OutlineLevel.new(value: value.to_i) if value
      end

      def yaml_outline_level_to(instance, _doc)
        instance.outline_level&.value
      end

      def yaml_contextual_spacing_from(instance, value)
        return if value.nil?

        instance.contextual_spacing = Properties::ContextualSpacing.new(value: value)
      end

      def yaml_contextual_spacing_to(instance, _doc)
        instance.contextual_spacing&.value
      end

      def yaml_page_break_before_from(instance, value)
        return if value.nil?

        instance.page_break_before_wrapper = Properties::PageBreakBefore.new(value: value)
      end

      def yaml_page_break_before_to(instance, _doc)
        instance.page_break_before_wrapper&.value
      end

      def yaml_widow_control_from(instance, value)
        return if value.nil?

        instance.widow_control_wrapper = Properties::WidowControl.new(value: value)
      end

      def yaml_widow_control_to(instance, _doc)
        instance.widow_control_wrapper&.value
      end

      # XML mappings come AFTER attributes
      xml do
        element "pPr"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        # Style reference - maps w:pStyle w:val="..." to style attribute
        map_element "pStyle", to: :style, render_nil: false

        # Alignment - maps w:jc w:val="..." to alignment attribute
        map_element "jc", to: :alignment, render_nil: false

        # Spacing (complex object - WORKS)
        map_element "spacing", to: :spacing, render_nil: false

        # Indentation (complex object)
        map_element "ind", to: :indentation, render_nil: false

        # Outline level (wrapper object)
        map_element "outlineLvl", to: :outline_level, render_nil: false

        # Numbering properties (wrapped in w:numPr)
        map_element "numPr", to: :numbering_properties, render_nil: false

        # Keep options (only render if true)
        map_element "keepNext", to: :keep_next_wrapper, render_nil: false,
                                render_default: false
        map_element "keepLines", to: :keep_lines_wrapper, render_nil: false,
                                 render_default: false
        map_element "pageBreakBefore", to: :page_break_before_wrapper, render_nil: false,
                                       render_default: false
        map_element "widowControl", to: :widow_control_wrapper, render_nil: false,
                                    render_default: false

        # Spacing options (only render if true)
        map_element "contextualSpacing", to: :contextual_spacing, render_nil: false,
                                         render_default: false
        map_element "suppressLineNumbers", to: :suppress_line_numbers, render_nil: false,
                                           render_default: false

        # Bidirectional (only render if true)
        map_element "bidi", to: :bidirectional, render_nil: false,
                            render_default: false

        # East Asian typography
        map_element "autoSpaceDE", to: :auto_space_de, render_nil: false,
                                   render_default: false
        map_element "autoSpaceDN", to: :auto_space_dn, render_nil: false,
                                   render_default: false
        map_element "adjustRightInd", to: :adjust_right_ind, render_nil: false,
                                      render_default: false

        # Borders (complex object)
        map_element "pBdr", to: :borders, render_nil: false

        # Tabs (complex object - collection)
        map_element "tabs", to: :tabs, render_nil: false

        # Shading (complex object)
        map_element "shd", to: :shading, render_nil: false

        # Run properties (for pPr/rPr - style overrides)
        map_element "rPr", to: :run_properties, render_nil: false

        # Section properties (paragraph-level section breaks)
        map_element "sectPr", to: :section_properties, render_nil: false
      end

      # Initialize with defaults and handle convenience attributes
      def initialize(attrs = {})
        # Save wrapper attribute values before super clears them
        keep_next_val = attrs.key?(:keep_next) ? attrs.delete(:keep_next) : nil
        keep_lines_val = attrs.key?(:keep_lines) ? attrs.delete(:keep_lines) : nil
        page_break_before_val = attrs.key?(:page_break_before) ? attrs.delete(:page_break_before) : nil
        widow_control_val = attrs.key?(:widow_control) ? attrs.delete(:widow_control) : nil
        style_val = attrs.key?(:style) ? attrs.delete(:style) : nil

        super

        # Set wrapper attributes after super (super clears them)
        self.keep_next = keep_next_val if keep_next_val
        self.keep_lines = keep_lines_val if keep_lines_val
        self.page_break_before = page_break_before_val if page_break_before_val
        self.widow_control = widow_control_val unless widow_control_val.nil?
        self.style = style_val if style_val

        # Convert flat attributes to wrapper objects (Pattern 0: after super)
        convert_flat_attributes!
      end

      # Convert flat convenience attributes to proper wrapper objects
      # This handles cases like ParagraphProperties.new(spacing_before: 120)
      # where the flat attribute is set but the wrapper object is not
      def convert_flat_attributes!
        # Style - convert string to StyleReference wrapper
        self.style = Properties::StyleReference.new(value: @style) if @style.is_a?(String)

        # Alignment - convert string to Alignment wrapper
        self.alignment = Properties::Alignment.new(value: @alignment) if @alignment.is_a?(String)

        # Spacing - create spacing object from flat spacing attributes
        if (@spacing_before || @spacing_after || @line_spacing || @line_rule) && !@spacing
          self.spacing = Properties::Spacing.new
          spacing.before = @spacing_before if @spacing_before
          spacing.after = @spacing_after if @spacing_after
          spacing.line = @line_spacing.to_i if @line_spacing
          spacing.line_rule = @line_rule if @line_rule
        end

        # Indentation - create indentation object from flat indent attributes
        if (@indent_left || @indent_right || @indent_first_line) && !@indentation
          self.indentation = Properties::Indentation.new
          indentation.left = @indent_left if @indent_left
          indentation.right = @indent_right if @indent_right
          indentation.first_line = @indent_first_line if @indent_first_line
        end

        # Run properties from flat attributes
        return unless @run_properties && !@run_properties.is_a?(RunProperties)

        rp = RunProperties.new
        rp.bold = @run_properties[:bold] if @run_properties[:bold]
        rp.italic = @run_properties[:italic] if @run_properties[:italic]
        rp.underline = @run_properties[:underline] if @run_properties[:underline]
        rp.color = @run_properties[:color] if @run_properties[:color]
        rp.font = @run_properties[:font] if @run_properties[:font]
        rp.size = @run_properties[:size] if @run_properties[:size]
        @run_properties = rp
      end

      # Set left indent (alias for indentation.left)
      #
      # @param value [Integer] Left indent in twips
      # @return [self] For method chaining
      def left_indent=(value)
        self.indentation ||= Properties::Indentation.new
        indentation.left = value
        self
      end

      # Boolean predicate for keep_next
      #
      # @return [Boolean] True if keep_next is set
      def keep_next?
        val = keep_next_wrapper
        return false if val.nil?

        val = val.value if val.is_a?(Properties::KeepNext)
        val == true
      end
      alias keep_next keep_next?

      # Boolean setter for keep_next
      #
      # @param value [Boolean] True to enable keep_next
      def keep_next=(value)
        self.keep_next_wrapper = case value
                                 when Properties::KeepNext
                                   value
                                 when true, false
                                   value ? Properties::KeepNext.new(value: true) : nil
                                 when nil
                                   nil
                                 else
                                   value
                                 end
      end

      # Boolean predicate for keep_lines
      #
      # @return [Boolean] True if keep_lines is set
      def keep_lines?
        val = keep_lines_wrapper
        return false if val.nil?

        val = val.value if val.is_a?(Properties::KeepLines)
        val == true
      end
      alias keep_lines keep_lines?

      # Boolean setter for keep_lines
      #
      # @param value [Boolean] True to enable keep_lines
      def keep_lines=(value)
        self.keep_lines_wrapper = case value
                                  when Properties::KeepLines
                                    value
                                  when true, false
                                    value ? Properties::KeepLines.new(value: true) : nil
                                  when nil
                                    nil
                                  else
                                    value
                                  end
      end

      # Boolean predicate for page_break_before
      #
      # @return [Boolean] True if page_break_before is set
      def page_break_before?
        val = page_break_before_wrapper
        return false if val.nil?

        val = val.value if val.is_a?(Properties::PageBreakBefore)
        val == true
      end
      alias page_break_before page_break_before?

      # Boolean setter for page_break_before
      #
      # @param value [Boolean] True to enable page_break_before
      def page_break_before=(value)
        self.page_break_before_wrapper = case value
                                         when Properties::PageBreakBefore
                                           value
                                         when true, false
                                           value ? Properties::PageBreakBefore.new(value: true) : nil
                                         when nil
                                           nil
                                         else
                                           value
                                         end
      end

      # Boolean predicate for widow_control
      #
      # @return [Boolean] True if widow_control is set
      def widow_control?
        val = widow_control_wrapper
        return true if val.nil? # default is true

        val = val.value if val.is_a?(Properties::WidowControl)
        val == true
      end
      alias widow_control widow_control?

      # Boolean setter for widow_control
      #
      # @param value [Boolean] True to enable widow_control
      def widow_control=(value)
        self.widow_control_wrapper = case value
                                     when Properties::WidowControl
                                       value
                                     when true
                                       Properties::WidowControl.new(value: true)
                                     when false
                                       Properties::WidowControl.new(value: false)
                                     when nil
                                       nil
                                     else
                                       value
                                     end
      end
    end
  end
end
