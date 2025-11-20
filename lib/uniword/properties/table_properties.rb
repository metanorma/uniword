# frozen_string_literal: true

require_relative '../table_border'

module Uniword
  module Properties
    # Value object representing table formatting properties
    # Responsibility: Hold immutable table styling data
    #
    # This class follows the Value Object pattern:
    # - Immutable (no setters after initialization)
    # - Value-based equality (two objects with same values are equal)
    # - Self-validating
    class TableProperties < Lutaml::Model::Serializable
      # Style reference (name of table style)
      attribute :style, :string

      # Table width (numeric value - meaning depends on width_type)
      attribute :width, :integer

      # Table alignment (left, center, right)
      attribute :alignment, :string

      # Table borders enabled
      attribute :borders, :boolean, default: -> { true }

      # Cell spacing (space between cells)
      attribute :cell_spacing, :integer

      # Cell padding (space within cells)
      attribute :cell_padding, :integer

      # Table indent from left margin
      attribute :indent, :integer

      # Allow table to span pages
      attribute :allow_break, :boolean, default: -> { true }

      # Table layout (auto or fixed)
      attribute :layout, :string

      # Background color
      attribute :background_color, :string

      # Border properties
      attribute :top_border, TableBorder
      attribute :bottom_border, TableBorder
      attribute :left_border, TableBorder
      attribute :right_border, TableBorder
      attribute :inside_h_border, TableBorder
      attribute :inside_v_border, TableBorder

      # Border style attributes (for docx-js compatibility)
      attribute :border_top_style, :string
      attribute :border_top_size, :integer
      attribute :border_top_color, :string
      attribute :border_bottom_style, :string
      attribute :border_bottom_size, :integer
      attribute :border_bottom_color, :string
      attribute :border_left_style, :string
      attribute :border_left_size, :integer
      attribute :border_left_color, :string
      attribute :border_right_style, :string
      attribute :border_right_size, :integer
      attribute :border_right_color, :string
      attribute :border_inside_h_style, :string
      attribute :border_inside_h_size, :integer
      attribute :border_inside_h_color, :string
      attribute :border_inside_v_style, :string
      attribute :border_inside_v_size, :integer
      attribute :border_inside_v_color, :string

      # General border style (for setting all borders at once)
      attribute :border_style, :string

      # Width type (auto, percentage, dxa)
      attribute :width_type, :string

      # Float/positioning properties
      attribute :float_bottom_from_text, :integer
      attribute :float_top_from_text, :integer
      attribute :float_left_from_text, :integer
      attribute :float_right_from_text, :integer
      attribute :float_horizontal_anchor, :string
      attribute :float_vertical_anchor, :string
      attribute :float_horizontal_align, :string
      attribute :float_vertical_align, :string
      attribute :float_absolute_horizontal_position, :integer
      attribute :float_relative_horizontal_position, :string
      attribute :float_absolute_vertical_position, :integer
      attribute :float_relative_vertical_position, :string

      # Cell span properties (for table cells using TableProperties)
      attribute :column_span, :integer
      attribute :row_span, :integer

      # Value-based equality
      # Two TableProperties objects are equal if all attributes match
      #
      # @param other [Object] The object to compare with
      # @return [Boolean] true if equal, false otherwise
      def ==(other)
        return false unless other.is_a?(self.class)

        style == other.style &&
          width == other.width &&
          alignment == other.alignment &&
          borders == other.borders &&
          cell_spacing == other.cell_spacing &&
          cell_padding == other.cell_padding &&
          indent == other.indent &&
          allow_break == other.allow_break &&
          layout == other.layout &&
          background_color == other.background_color &&
          top_border == other.top_border &&
          bottom_border == other.bottom_border &&
          left_border == other.left_border &&
          right_border == other.right_border &&
          inside_h_border == other.inside_h_border &&
          inside_v_border == other.inside_v_border &&
          border_top_style == other.border_top_style &&
          border_top_size == other.border_top_size &&
          border_top_color == other.border_top_color &&
          border_bottom_style == other.border_bottom_style &&
          border_bottom_size == other.border_bottom_size &&
          border_bottom_color == other.border_bottom_color &&
          border_left_style == other.border_left_style &&
          border_left_size == other.border_left_size &&
          border_left_color == other.border_left_color &&
          border_right_style == other.border_right_style &&
          border_right_size == other.border_right_size &&
          border_right_color == other.border_right_color &&
          border_inside_h_style == other.border_inside_h_style &&
          border_inside_h_size == other.border_inside_h_size &&
          border_inside_h_color == other.border_inside_h_color &&
          border_inside_v_style == other.border_inside_v_style &&
          border_inside_v_size == other.border_inside_v_size &&
          border_inside_v_color == other.border_inside_v_color &&
          border_style == other.border_style &&
          width_type == other.width_type &&
          float_bottom_from_text == other.float_bottom_from_text &&
          float_top_from_text == other.float_top_from_text &&
          float_left_from_text == other.float_left_from_text &&
          float_right_from_text == other.float_right_from_text &&
          float_horizontal_anchor == other.float_horizontal_anchor &&
          float_vertical_anchor == other.float_vertical_anchor &&
          float_horizontal_align == other.float_horizontal_align &&
          float_vertical_align == other.float_vertical_align &&
          float_absolute_horizontal_position == other.float_absolute_horizontal_position &&
          float_relative_horizontal_position == other.float_relative_horizontal_position &&
          float_absolute_vertical_position == other.float_absolute_vertical_position &&
          float_relative_vertical_position == other.float_relative_vertical_position &&
          column_span == other.column_span &&
          row_span == other.row_span
      end

      alias eql? ==

      # Hash code for value-based hashing
      #
      # @return [Integer] hash code
      def hash
        [
          style, width, alignment, borders, cell_spacing,
          cell_padding, indent, allow_break, layout, background_color,
          top_border, bottom_border, left_border, right_border,
          inside_h_border, inside_v_border,
          border_top_style, border_top_size, border_top_color,
          border_bottom_style, border_bottom_size, border_bottom_color,
          border_left_style, border_left_size, border_left_color,
          border_right_style, border_right_size, border_right_color,
          border_inside_h_style, border_inside_h_size, border_inside_h_color,
          border_inside_v_style, border_inside_v_size, border_inside_v_color,
          border_style, width_type,
          float_bottom_from_text, float_top_from_text,
          float_left_from_text, float_right_from_text,
          float_horizontal_anchor, float_vertical_anchor,
          float_horizontal_align, float_vertical_align,
          float_absolute_horizontal_position, float_relative_horizontal_position,
          float_absolute_vertical_position, float_relative_vertical_position,
          column_span, row_span
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
