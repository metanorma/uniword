# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Table formatting properties
    #
    # Represents w:tblPr element containing table-level formatting.
    # Used in StyleSets and table elements.
    class TableProperties < Lutaml::Model::Serializable
      # Pattern 0: ATTRIBUTES FIRST, then XML mappings

      # Style reference
      attribute :style, TableStyle

      # Table width (wrapper class)
      attribute :table_width, Uniword::Properties::TableWidth

      # Table alignment (wrapper class for w:jc element)
      attribute :alignment, Uniword::Properties::TableJustification

      # Table indentation
      attribute :indent, :integer # In twips

      # Cell spacing
      attribute :cell_spacing, :integer # In twips

      # Table layout (wrapper class)
      attribute :table_layout, Uniword::Properties::TableLayout

      # Borders flag
      attribute :borders, :boolean, default: -> { false }

      # Allow break flag
      attribute :allow_break, :boolean, default: -> { true }

      # Individual border properties (stored as flat attributes)
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

      # Table shading (wrapper class with themeFill support)
      attribute :shading, Uniword::Properties::Shading

      # Table cell margins (wrapper class)
      attribute :table_cell_margin, Uniword::Properties::TableCellMargin

      # Table indent (wrapper class)
      attribute :table_indent, Uniword::Properties::TableIndent

      # Table look - conditional formatting flags (wrapper class)
      attribute :table_look, Uniword::Properties::TableLook

      # Table caption
      attribute :caption, Uniword::Properties::TableCaption

      # Table borders
      attribute :table_borders, TableBorders

      # XML mappings come AFTER attributes
      xml do
        element "tblPr"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        # High-priority mappings (Phase 4 Session 1-2)
        map_element "tblW", to: :table_width, render_nil: false
        map_element "shd", to: :shading, render_nil: false
        map_element "tblCellMar", to: :table_cell_margin, render_nil: false
        map_element "tblLook", to: :table_look, render_nil: false
        map_element "tblCaption", to: :caption, render_nil: false

        # Table indentation - critical for table styles
        map_element "tblInd", to: :table_indent, render_nil: false
        # Table cell spacing
        map_element "tblCellSpacing", to: :cell_spacing, render_nil: false
        # Table alignment
        map_element "jc", to: :alignment, render_nil: false
        # Table layout
        map_element "tblLayout", to: :table_layout, render_nil: false
        # Table style reference
        map_element "tblStyle", to: :style, render_nil: false

        # Table borders
        map_element "tblBorders", to: :table_borders, render_nil: false
      end

      # Initialize with defaults and handle convenience attributes
      def initialize(attrs = {})
        # Extract border attributes and convert to flat attributes
        border_attrs = {}
        %i[top bottom left right inside_h inside_v].each do |side|
          key = "#{side}_border"
          border_attrs[side] = attrs.delete(key) || attrs.delete(key.to_sym) if attrs.key?(key) || attrs.key?(key.to_sym)
        end

        # Extract other convenience attributes
        cell_padding_value = attrs.delete(:cell_padding) || attrs.delete("cell_padding")
        cell_spacing_value = attrs.delete(:cell_spacing) || attrs.delete("cell_spacing")

        # Handle width: parameter (creates table_width wrapper)
        width_value = attrs.delete(:width) || attrs.delete("width")
        # Handle alignment: parameter (creates jc element wrapper)
        alignment_value = attrs.delete(:alignment) || attrs.delete("alignment")

        super

        @borders ||= false
        @allow_break = true if @allow_break.nil?

        # Set borders from extracted attributes
        border_attrs.each do |side, value|
          send("#{side}_border=", value)
        end

        # Set cell padding if provided
        self.cell_padding = cell_padding_value if cell_padding_value

        # Set cell spacing if provided
        self.cell_spacing = cell_spacing_value if cell_spacing_value

        # Set width if provided (creates TableWidth wrapper)
        if width_value
          self.table_width = Properties::TableWidth.new
          table_width.w = width_value.to_i
          table_width.type ||= "dxa"
        end

        # Set alignment if provided (creates TableJustification wrapper)
        return unless alignment_value

        self.alignment = Properties::TableJustification.new
        alignment.value = alignment_value
      end

      # Get table width
      #
      # @return [Integer, nil] Table width value
      def width
        table_width&.value
      end

      # Set table width
      #
      # @param value [Integer] Width value
      # @return [self] For method chaining
      def width=(value)
        self.table_width ||= Properties::TableWidth.new
        table_width.value = value
        self
      end

      # Get cell padding (alias for table_cell_margin)
      #
      # @return [Integer, nil] Cell padding value
      def cell_padding
        # Return the padding value if all sides are the same
        return nil unless table_cell_margin

        margins = [table_cell_margin.top, table_cell_margin.left,
                   table_cell_margin.bottom, table_cell_margin.right].compact
        margins.first if margins.uniq.size == 1
      end

      # Set cell padding
      #
      # @param value [Integer, TableCellMargin, Hash] Cell margin settings
      # @return [self] For method chaining
      def cell_padding=(value)
        case value
        when Integer
          self.table_cell_margin ||= Properties::TableCellMargin.new
          table_cell_margin.top = value
          table_cell_margin.left = value
          table_cell_margin.bottom = value
          table_cell_margin.right = value
        when Properties::TableCellMargin
          self.table_cell_margin = value
        when Hash
          self.table_cell_margin ||= Properties::TableCellMargin.new
          table_cell_margin.top = value[:top] || value[:all]
          table_cell_margin.left = value[:left] || value[:all]
          table_cell_margin.bottom = value[:bottom] || value[:all]
          table_cell_margin.right = value[:right] || value[:all]
        else
          self.table_cell_margin = value
        end
        self
      end

      # Get top border
      #
      # @return [BorderInfo, nil] Top border properties
      def top_border
        border_to_object(:top)
      end

      # Set top border
      #
      # @param value [TableBorder, Hash] Border configuration
      # @return [self] For method chaining
      def top_border=(value)
        set_border(:top, value)
        self
      end

      # Get bottom border
      #
      # @return [BorderInfo, nil] Bottom border properties
      def bottom_border
        border_to_object(:bottom)
      end

      # Set bottom border
      #
      # @param value [TableBorder, Hash] Border configuration
      # @return [self] For method chaining
      def bottom_border=(value)
        set_border(:bottom, value)
        self
      end

      # Get left border
      #
      # @return [BorderInfo, nil] Left border properties
      def left_border
        border_to_object(:left)
      end

      # Set left border
      #
      # @param value [TableBorder, Hash] Border configuration
      # @return [self] For method chaining
      def left_border=(value)
        set_border(:left, value)
        self
      end

      # Get right border
      #
      # @return [BorderInfo, nil] Right border properties
      def right_border
        border_to_object(:right)
      end

      # Set right border
      #
      # @param value [TableBorder, Hash] Border configuration
      # @return [self] For method chaining
      def right_border=(value)
        set_border(:right, value)
        self
      end

      # Get inside horizontal border
      #
      # @return [BorderInfo, nil] Inside horizontal border properties
      def inside_h_border
        border_to_object(:inside_h)
      end

      # Set inside horizontal border
      #
      # @param value [TableBorder, Hash] Border configuration
      # @return [self] For method chaining
      def inside_h_border=(value)
        set_border(:inside_h, value)
        self
      end

      # Get inside vertical border
      #
      # @return [BorderInfo, nil] Inside vertical border properties
      def inside_v_border
        border_to_object(:inside_v)
      end

      # Set inside vertical border
      #
      # @param value [TableBorder, Hash] Border configuration
      # @return [self] For method chaining
      def inside_v_border=(value)
        set_border(:inside_v, value)
        self
      end

      private

      # Simple struct for border info with accessor methods
      BorderInfo = Struct.new(:style, :size, :color)

      # Convert border attributes to BorderInfo object
      #
      # @param side [Symbol] Border side (:top, :bottom, :left, :right, :inside_h, :inside_v)
      # @return [BorderInfo, nil] Border properties object
      def border_to_object(side)
        style = send("border_#{side}_style")
        return nil unless style

        BorderInfo.new(
          style: style,
          size: send("border_#{side}_size"),
          color: send("border_#{side}_color")
        )
      end

      # Set border attributes from TableBorder or Hash
      #
      # @param side [Symbol] Border side
      # @param value [TableBorder, Hash] Border configuration
      def set_border(side, value)
        case value
        when Uniword::TableBorder
          send("border_#{side}_style=", value.style)
          send("border_#{side}_size=", value.width)
          send("border_#{side}_color=", value.color)
        when Hash
          send("border_#{side}_style=", value[:style])
          send("border_#{side}_size=", value[:size])
          send("border_#{side}_color=", value[:color])
        end
      end

      # Convert border attributes to hash (deprecated, use border_to_object)
      #
      # @param side [Symbol] Border side (:top, :bottom, :left, :right, :inside_h, :inside_v)
      # @return [Hash, nil] Border properties hash
      def border_to_hash(side)
        border_to_object(side)&.to_h
      end
    end
  end
end
