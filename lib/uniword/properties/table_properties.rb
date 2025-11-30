# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Properties
    # Table formatting properties
    #
    # Represents w:tblPr element containing table-level formatting.
    # Used in StyleSets and table elements.
    class TableProperties < Lutaml::Model::Serializable
      # Pattern 0: ATTRIBUTES FIRST, then XML mappings

      # Style reference
      attribute :style, :string

      # Table width
      attribute :width, :integer
      attribute :width_type, :string  # auto, dxa (twips), pct, nil

      # Table alignment
      attribute :alignment, :string   # left, center, right

      # Table indentation
      attribute :indent, :integer     # In twips

      # Cell spacing
      attribute :cell_spacing, :integer  # In twips

      # Table layout
      attribute :layout, :string      # autofit, fixed

      # Borders flag
      attribute :borders, :boolean, default: -> { false }

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

      # Background color
      attribute :background_color, :string  # RGB hex

      # Cell margins (in twips)
      attribute :cell_margin_top, :integer
      attribute :cell_margin_bottom, :integer
      attribute :cell_margin_left, :integer
      attribute :cell_margin_right, :integer

      # Table look (style flags as hex string)
      attribute :look, :string

      # XML mappings come AFTER attributes
      xml do
        element 'tblPr'
        namespace Ooxml::Namespaces::WordProcessingML
        mixed_content

        # All table properties parsed manually, serialization TODO for Session 3
        # map_element 'tblStyle', to: :style, render_nil: false
        # map_element 'tblW', render_nil: false
        # map_element 'jc', to: :alignment, render_nil: false
        # map_element 'tblInd', render_nil: false
        # map_element 'tblCellSpacing', render_nil: false
        # map_element 'tblLayout', to: :layout, render_nil: false
        # map_element 'tblBorders', render_nil: false
        # map_element 'tblLook', to: :look, render_nil: false
        # map_element 'shd', render_nil: false
      end

      # Initialize with defaults
      def initialize(attrs = {})
        super
        @borders ||= false
      end
    end
  end
end