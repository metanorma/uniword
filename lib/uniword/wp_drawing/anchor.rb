# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module WpDrawing
    # Anchor drawing object
    # Positioned/floating, not inline with text
    class Anchor < Lutaml::Model::Serializable
      # PATTERN 0: Attributes FIRST
      # Distance attributes (same as Inline)
      attribute :dist_t, :integer
      attribute :dist_b, :integer
      attribute :dist_l, :integer
      attribute :dist_r, :integer

      # Positioning attributes (unique to Anchor)
      attribute :relative_height, :integer
      attribute :behind_doc, :string
      attribute :locked, :string
      attribute :layout_in_cell, :string
      attribute :allow_overlap, :string

      # Word 2010 namespace attributes for anchor tracking
      attribute :anchor_id, Uniword::Properties::Word2010IdValue
      attribute :edit_id, Uniword::Properties::Word2010IdValue

      # Child elements
      attribute :simple_pos, SimplePos
      attribute :position_h, PositionH
      attribute :position_v, PositionV
      attribute :extent, Extent
      attribute :effect_extent, EffectExtent
      attribute :wrap_none, WrapNone
      attribute :wrap_square, WrapSquare
      attribute :wrap_tight, WrapTight
      attribute :wrap_top_and_bottom, WrapTopAndBottom
      attribute :doc_properties, DocProperties
      attribute :non_visual_props, NonVisualDrawingProps
      attribute :graphic, Drawingml::Graphic

      xml do
        element "anchor"
        namespace Uniword::Ooxml::Namespaces::WordProcessingDrawing
        mixed_content

        # Distance attributes
        map_attribute "distT", to: :dist_t, render_nil: false
        map_attribute "distB", to: :dist_b, render_nil: false
        map_attribute "distL", to: :dist_l, render_nil: false
        map_attribute "distR", to: :dist_r, render_nil: false

        # Positioning attributes
        map_attribute "relativeHeight", to: :relative_height, render_nil: false
        map_attribute "behindDoc", to: :behind_doc, render_nil: false
        map_attribute "locked", to: :locked, render_nil: false
        map_attribute "layoutInCell", to: :layout_in_cell, render_nil: false
        map_attribute "allowOverlap", to: :allow_overlap, render_nil: false

        # Word 2010 namespace attributes
        map_attribute "anchorId", to: :anchor_id, render_nil: false
        map_attribute "editId", to: :edit_id, render_nil: false

        # Child elements
        map_element "simplePos", to: :simple_pos, render_nil: false
        map_element "positionH", to: :position_h, render_nil: false
        map_element "positionV", to: :position_v, render_nil: false
        map_element "extent", to: :extent, render_nil: false
        map_element "effectExtent", to: :effect_extent, render_nil: false
        map_element "wrapNone", to: :wrap_none, render_nil: false
        map_element "wrapSquare", to: :wrap_square, render_nil: false
        map_element "wrapTight", to: :wrap_tight, render_nil: false
        map_element "wrapTopAndBottom", to: :wrap_top_and_bottom,
                                        render_nil: false
        map_element "docPr", to: :doc_properties, render_nil: false
        map_element "cNvGraphicFramePr", to: :non_visual_props,
                                         render_nil: false
        map_element "graphic", to: :graphic, render_nil: false
      end
    end
  end
end
