# frozen_string_literal: true

# WP Drawing (WordprocessingDrawing) namespace module
# This file explicitly autoloads all WpDrawing classes
# Using explicit autoload instead of dynamic Dir[] for maintainability
#
# Namespace: http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing
# Prefix: wp:

require 'lutaml/model'

module Uniword
  module WpDrawing
    # Drawing Containers (2)
    autoload :Anchor, 'uniword/wp_drawing/anchor'
    autoload :Inline, 'uniword/wp_drawing/inline'

    # Size & Dimensions (4)
    autoload :Extent, 'uniword/wp_drawing/extent'
    autoload :EffectExtent, 'uniword/wp_drawing/effect_extent'
    autoload :SizeRelH, 'uniword/wp_drawing/size_rel_h'
    autoload :SizeRelV, 'uniword/wp_drawing/size_rel_v'

    # Positioning (6)
    autoload :PositionH, 'uniword/wp_drawing/position_h'
    autoload :PositionV, 'uniword/wp_drawing/position_v'
    autoload :SimplePos, 'uniword/wp_drawing/simple_pos'
    autoload :PosOffset, 'uniword/wp_drawing/pos_offset'
    autoload :Align, 'uniword/wp_drawing/align'
    autoload :Start, 'uniword/wp_drawing/start'

    # Properties (4)
    autoload :DocProperties, 'uniword/wp_drawing/doc_properties'
    autoload :DocPr, 'uniword/wp_drawing/doc_pr'
    autoload :NonVisualDrawingProps, 'uniword/wp_drawing/non_visual_drawing_props'
    autoload :CNvGraphicFramePr, 'uniword/wp_drawing/c_nv_graphic_frame_pr'

    # Wrapping (6)
    autoload :WrapNone, 'uniword/wp_drawing/wrap_none'
    autoload :WrapSquare, 'uniword/wp_drawing/wrap_square'
    autoload :WrapTight, 'uniword/wp_drawing/wrap_tight'
    autoload :WrapThrough, 'uniword/wp_drawing/wrap_through'
    autoload :WrapPolygon, 'uniword/wp_drawing/wrap_polygon'
    autoload :WrapTopAndBottom, 'uniword/wp_drawing/wrap_top_and_bottom'

    # Layout & Visibility (6)
    autoload :RelativeHeight, 'uniword/wp_drawing/relative_height'
    autoload :BehindDoc, 'uniword/wp_drawing/behind_doc'
    autoload :Hidden, 'uniword/wp_drawing/hidden'
    autoload :Locked, 'uniword/wp_drawing/locked'
    autoload :AllowOverlap, 'uniword/wp_drawing/allow_overlap'
    autoload :LayoutInCell, 'uniword/wp_drawing/layout_in_cell'

    # Path Elements (1)
    autoload :LineTo, 'uniword/wp_drawing/line_to'
  end
end