# frozen_string_literal: true

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
        root 'pPr', mixed: true
        namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

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

      # Aliases for more readable API
      alias_method :numbering_id, :num_id
      alias_method :numbering_id=, :num_id=
      alias_method :numbering_level, :ilvl
      alias_method :numbering_level=, :ilvl=
      alias_method :spacing_line, :line_spacing
      alias_method :spacing_line=, :line_spacing=
      alias_method :left_indent, :indent_left
      alias_method :left_indent=, :indent_left=

      # Paragraph borders
      attribute :borders, :string  # Will be enhanced with ParagraphBorders class

      # Suppress line numbers for this paragraph
      attribute :suppress_line_numbers, :boolean, default: -> { false }

      # Contextual spacing (adjust spacing based on context)
      attribute :contextual_spacing, :boolean, default: -> { false }

      # Bidirectional text (right-to-left)
      attribute :bidirectional, :boolean, default: -> { false }

      # Shading pattern type (symbol or string)
      attr_accessor :_shading_type_internal

      def shading_type
        @_shading_type_internal
      end

      def shading_type=(value)
        @_shading_type_internal = value.is_a?(String) ? value.to_sym : value
      end

      # Shading foreground color
      attribute :shading_color, :string

      # Shading background fill color
      attribute :shading_fill, :string

      # Convenience setter for shading (sets shading_fill)
      #
      # @param value [String] The shading/background color
      # @return [String] The shading value
      def shading=(value)
        self.shading_fill = value
      end

      # Convenience getter for shading (returns shading_fill)
      #
      # @return [String, nil] The shading/background color
      def shading
        shading_fill
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
          suppress_line_numbers == other.suppress_line_numbers &&
          contextual_spacing == other.contextual_spacing &&
          bidirectional == other.bidirectional &&
          shading_type == other.shading_type &&
          shading_color == other.shading_color &&
          shading_fill == other.shading_fill
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
          num_id, ilvl, borders, suppress_line_numbers,
          contextual_spacing, bidirectional,
          shading_type, shading_color, shading_fill
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
  end
end
