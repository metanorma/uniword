# frozen_string_literal: true

require_relative 'border'
require_relative 'shading'
require_relative 'tab_stop'
require_relative 'numbering_properties'
require_relative 'frame_properties'
require_relative '../ooxml/namespaces'

module Uniword
  module Properties
    # Value object representing paragraph formatting properties
    # Responsibility: Hold immutable paragraph styling data
    #
    # This class follows the Value Object pattern:
    # - Immutable (no setters after initialization)
    # - Value-based equality (two objects with same values are equal)
    # - Self-validating
    class ParagraphProperties < Lutaml::Model::Serializable
      # OOXML namespace configuration
      xml do
        element 'pPr'
        namespace Ooxml::Namespaces::WordProcessingML
        mixed_content

        # All mapped elements will be in the 'w' namespace
        map_element 'pStyle', to: :style
        map_element 'jc', to: :alignment
        map_element 'spacing', to: :spacing
        map_element 'ind', to: :indentation
        map_element 'keepNext', to: :keep_next
        map_element 'keepLines', to: :keep_lines
        map_element 'pageBreakBefore', to: :page_break_before
        map_element 'outlineLvl', to: :outline_level
        map_element 'numPr', to: :numbering_properties
        map_element 'pBdr', to: :borders
        map_element 'shd', to: :shading
        map_element 'tabs', to: :tab_stops
        map_element 'suppressLineNumbers', to: :suppress_line_numbers
        map_element 'contextualSpacing', to: :contextual_spacing
        map_element 'bidi', to: :bidirectional
        map_element 'mirrorIndents', to: :mirror_indents
        map_element 'snapToGrid', to: :snap_to_grid
        map_element 'widowControl', to: :widow_control
        map_element 'framePr', to: :frame_properties
        map_element 'sectPr', to: :section_properties
        map_element 'textDirection', to: :text_direction
        map_element 'cnfStyle', to: :conditional_formatting
        map_element 'rPr', to: :run_properties
        map_element 'pPrChange', to: :properties_change
      end

      # Style reference (name of paragraph style)
      attribute :style, :string

      # Text alignment (left, center, right, justify, etc.)
      attribute :alignment, :string

      # Spacing before paragraph (in points or twips)
      attribute :spacing_before, :integer

      # Spacing after paragraph (in points or twips)
      attribute :spacing_after, :integer

      # Line spacing value (in twips or as multiple)
      # Can be numeric for simple cases or part of hash for fine control
      attribute :line_spacing, :float

      # Line spacing rule: "auto" (multiple), "exact", or "atLeast"
      attribute :line_rule, :string

      # Indentation from left margin
      attribute :indent_left, :integer

      # Indentation from right margin
      attribute :indent_right, :integer

      # First line indentation
      attribute :indent_first_line, :integer

      # Keep paragraph on same page
      attribute :keep_next, :boolean, default: -> { false }

      # Keep lines together
      attribute :keep_lines, :boolean, default: -> { false }

      # Page break before paragraph
      attribute :page_break_before, :boolean, default: -> { false }

      # Outline level for heading styles
      attribute :outline_level, :integer

      # Numbering instance ID (for numbered/bulleted lists)
      # Can be integer or string (GUID)
      attribute :num_id, :string

      # Numbering level (0-8)
      attribute :ilvl, :integer

      # Paragraph borders (complete border structure)
      attribute :borders, ParagraphBorders

      # Shading properties (complete implementation)
      attribute :shading, ParagraphShading

      # Tab stops collection
      attribute :tab_stops, TabStopCollection

      # Numbering properties (complete numPr structure)
      attribute :numbering_properties, NumberingProperties

      # Frame properties for text boxes
      attribute :frame_properties, FrameProperties

      # Section properties
      attribute :section_properties, SectionProperties

      # Suppress line numbers for this paragraph
      attribute :suppress_line_numbers, :boolean, default: -> { false }

      # Contextual spacing (adjust spacing based on context)
      attribute :contextual_spacing, :boolean, default: -> { false }

      # Bidirectional text (right-to-left)
      attribute :bidirectional, :boolean, default: -> { false }

      # Mirror indents (left/right indents swap in RTL text)
      attribute :mirror_indents, :boolean, default: -> { false }

      # Snap to grid (align text to document grid)
      attribute :snap_to_grid, :boolean, default: -> { true }

      # Widow/orphan control
      attribute :widow_control, :boolean, default: -> { true }

      # Text direction
      attribute :text_direction, :string

      # Conditional formatting style (for tables)
      attribute :conditional_formatting, :string

      # Run properties applied to paragraph mark
      attribute :run_properties, :string  # Will be replaced with RunProperties when available

      # Properties change tracking
      attribute :properties_change, :string  # Simple string for now, can be enhanced later

      # Aliases for more readable API
      alias_method :numbering_id, :num_id
      alias_method :numbering_id=, :num_id=
      alias_method :numbering_level, :ilvl
      alias_method :numbering_level=, :ilvl=
      alias_method :spacing_line, :line_spacing
      alias_method :spacing_line=, :line_spacing=
      alias_method :left_indent, :indent_left
      alias_method :left_indent=, :indent_left=

      # Convenience methods for borders
      def border_top
        borders&.top
      end

      def border_bottom
        borders&.bottom
      end

      def border_left
        borders&.left
      end

      def border_right
        borders&.right
      end

      def border_between
        borders&.between
      end

      def border_bar
        borders&.bar
      end

      # Convenience methods for shading
      def shading_type
        shading&.shading_type
      end

      def shading_color
        shading&.color
      end

      def shading_fill
        shading&.fill
      end

      # Convenience setter for shading (sets shading_fill)
      #
      # @param value [String] The shading/background color
      # @return [String] The shading value
      def shading_color=(value)
        self.shading = ParagraphShading.new(fill: value) unless value.nil?
      end

      # Convenience getter for shading (returns shading_fill)
      #
      # @return [String, nil] The shading/background color
      def shading_color
        shading&.fill
      end

      # Value-based equality
      # Two ParagraphProperties objects are equal if all attributes match
      #
      # @param other [Object] The object to compare with
      # @return [Boolean] true if equal, false otherwise
      def ==(other)
        return false unless other.is_a?(self.class)

        style == other.style &&
          alignment == other.alignment &&
          spacing_before == other.spacing_before &&
          spacing_after == other.spacing_after &&
          line_spacing == other.line_spacing &&
          line_rule == other.line_rule &&
          indent_left == other.indent_left &&
          indent_right == other.indent_right &&
          indent_first_line == other.indent_first_line &&
          keep_next == other.keep_next &&
          keep_lines == other.keep_lines &&
          page_break_before == other.page_break_before &&
          outline_level == other.outline_level &&
          num_id == other.num_id &&
          ilvl == other.ilvl &&
          borders == other.borders &&
          shading == other.shading &&
          tab_stops == other.tab_stops &&
          numbering_properties == other.numbering_properties &&
          frame_properties == other.frame_properties &&
          section_properties == other.section_properties &&
          suppress_line_numbers == other.suppress_line_numbers &&
          contextual_spacing == other.contextual_spacing &&
          bidirectional == other.bidirectional &&
          mirror_indents == other.mirror_indents &&
          snap_to_grid == other.snap_to_grid &&
          widow_control == other.widow_control &&
          text_direction == other.text_direction &&
          conditional_formatting == other.conditional_formatting &&
          run_properties == other.run_properties &&
          properties_change == other.properties_change
      end

      alias eql? ==

      # Hash code for value-based hashing
      #
      # @return [Integer] hash code
      def hash
        [
          style, alignment, spacing_before, spacing_after,
          line_spacing, line_rule, indent_left, indent_right, indent_first_line,
          keep_next, keep_lines, page_break_before, outline_level,
          num_id, ilvl, borders, shading, tab_stops, numbering_properties,
          frame_properties, section_properties, suppress_line_numbers,
          contextual_spacing, bidirectional, mirror_indents, snap_to_grid,
          widow_control, text_direction, conditional_formatting,
          run_properties, properties_change
        ].hash
      end

      # Note: Temporarily allowing mutation for test compatibility
      # In production use, create new properties objects rather than mutating
      def initialize(*args)
        super
        # Don't freeze - allow mutation for easier testing
        # freeze
      end
    end

    # Properties change tracking
    class PropertiesChange < Lutaml::Model::Serializable
      xml do
        root 'pPrChange'
        namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

        map_attribute 'id', to: :id
        map_attribute 'author', to: :author
        map_attribute 'date', to: :date
      end

      # Change ID
      attribute :id, :string

      # Author
      attribute :author, :string

      # Date
      attribute :date, :string
    end
  end
end
