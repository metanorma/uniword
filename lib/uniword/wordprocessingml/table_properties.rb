# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Table formatting properties
    #
    # Represents w:tblPr element containing table-level formatting.
    # Used in StyleSets and table elements.
    class TableProperties < Lutaml::Model::Serializable
      # Pattern 0: ATTRIBUTES FIRST, then XML mappings

      # Style reference
      attribute :style, :string

      # Table width (wrapper class)
      attribute :table_width, Uniword::Properties::TableWidth

      # Table alignment
      attribute :alignment, :string # left, center, right

      # Table indentation
      attribute :indent, :integer # In twips

      # Cell spacing
      attribute :cell_spacing, :integer # In twips

      # Table layout
      attribute :layout, :string # autofit, fixed

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

      # Table look - conditional formatting flags (wrapper class)
      attribute :table_look, Uniword::Properties::TableLook

      # XML mappings come AFTER attributes
      xml do
        root 'tblPr'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        # High-priority mappings (Phase 4 Session 1-2)
        map_element 'tblW', to: :table_width, render_nil: false
        map_element 'shd', to: :shading, render_nil: false
        map_element 'tblCellMar', to: :table_cell_margin, render_nil: false
        map_element 'tblLook', to: :table_look, render_nil: false

        # TODO: Remaining mappings for Phase 4 Session 3+
        # map_element 'tblStyle', to: :style, render_nil: false
        # map_element 'jc', to: :alignment, render_nil: false
        # map_element 'tblInd', render_nil: false
        # map_element 'tblCellSpacing', render_nil: false
        # map_element 'tblLayout', to: :layout, render_nil: false
        # map_element 'tblBorders', render_nil: false
      end

      # Initialize with defaults
      def initialize(attrs = {})
        super
        @borders ||= false
        @allow_break = true if @allow_break.nil?
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
      # @return [TableCellMargin, nil] Cell margin settings
      def cell_padding
        table_cell_margin
      end

      # Set cell padding
      #
      # @param value [TableCellMargin, Hash] Cell margin settings
      # @return [self] For method chaining
      def cell_padding=(value)
        self.table_cell_margin = value
        self
      end

      # Get top border
      #
      # @return [Hash, nil] Top border properties
      def top_border
        border_to_hash(:top)
      end

      # Get bottom border
      #
      # @return [Hash, nil] Bottom border properties
      def bottom_border
        border_to_hash(:bottom)
      end

      # Get left border
      #
      # @return [Hash, nil] Left border properties
      def left_border
        border_to_hash(:left)
      end

      # Get right border
      #
      # @return [Hash, nil] Right border properties
      def right_border
        border_to_hash(:right)
      end

      # Get inside horizontal border
      #
      # @return [Hash, nil] Inside horizontal border properties
      def inside_h_border
        border_to_hash(:inside_h)
      end

      # Get inside vertical border
      #
      # @return [Hash, nil] Inside vertical border properties
      def inside_v_border
        border_to_hash(:inside_v)
      end

      private

      # Convert border attributes to hash
      #
      # @param side [Symbol] Border side (:top, :bottom, :left, :right, :inside_h, :inside_v)
      # @return [Hash, nil] Border properties hash
      def border_to_hash(side)
        style = send("border_#{side}_style")
        return nil unless style

        {
          style: style,
          size: send("border_#{side}_size"),
          color: send("border_#{side}_color")
        }
      end
    end
  end
end
