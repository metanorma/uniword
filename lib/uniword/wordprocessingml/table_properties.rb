# frozen_string_literal: true

require 'lutaml/model'
require_relative '../properties/table_width'
require_relative '../properties/shading'
require_relative '../properties/table_cell_margin'
require_relative '../properties/table_look'

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
      end
    end
  end
end