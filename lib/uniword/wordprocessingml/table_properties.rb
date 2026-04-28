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

      def initialize(attrs = {})
        super

        @borders ||= false
        @allow_break = true if @allow_break.nil?
      end
    end
  end
end
