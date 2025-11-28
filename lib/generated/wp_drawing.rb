# frozen_string_literal: true

# WP Drawing (WordprocessingDrawing) namespace
# Handles positioning and anchoring of drawings in Word documents
# Namespace: http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing
# Prefix: wp:

module Uniword
  module Generated
    module WpDrawing
      autoload :Align, File.expand_path('wp_drawing/align', __dir__)
      autoload :AllowOverlap, File.expand_path('wp_drawing/allow_overlap', __dir__)
      autoload :Anchor, File.expand_path('wp_drawing/anchor', __dir__)
      autoload :BehindDoc, File.expand_path('wp_drawing/behind_doc', __dir__)
      autoload :CNvGraphicFramePr, File.expand_path('wp_drawing/c_nv_graphic_frame_pr', __dir__)
      autoload :DocPr, File.expand_path('wp_drawing/doc_pr', __dir__)
      autoload :EffectExtent, File.expand_path('wp_drawing/effect_extent', __dir__)
      autoload :Extent, File.expand_path('wp_drawing/extent', __dir__)
      autoload :Hidden, File.expand_path('wp_drawing/hidden', __dir__)
      autoload :Inline, File.expand_path('wp_drawing/inline', __dir__)
      autoload :LayoutInCell, File.expand_path('wp_drawing/layout_in_cell', __dir__)
      autoload :LineTo, File.expand_path('wp_drawing/line_to', __dir__)
      autoload :Locked, File.expand_path('wp_drawing/locked', __dir__)
      autoload :PosOffset, File.expand_path('wp_drawing/pos_offset', __dir__)
      autoload :PositionH, File.expand_path('wp_drawing/position_h', __dir__)
      autoload :PositionV, File.expand_path('wp_drawing/position_v', __dir__)
      autoload :RelativeHeight, File.expand_path('wp_drawing/relative_height', __dir__)
      autoload :SimplePos, File.expand_path('wp_drawing/simple_pos', __dir__)
      autoload :SizeRelH, File.expand_path('wp_drawing/size_rel_h', __dir__)
      autoload :SizeRelV, File.expand_path('wp_drawing/size_rel_v', __dir__)
      autoload :Start, File.expand_path('wp_drawing/start', __dir__)
      autoload :WrapNone, File.expand_path('wp_drawing/wrap_none', __dir__)
      autoload :WrapPolygon, File.expand_path('wp_drawing/wrap_polygon', __dir__)
      autoload :WrapSquare, File.expand_path('wp_drawing/wrap_square', __dir__)
      autoload :WrapThrough, File.expand_path('wp_drawing/wrap_through', __dir__)
      autoload :WrapTight, File.expand_path('wp_drawing/wrap_tight', __dir__)
      autoload :WrapTopAndBottom, File.expand_path('wp_drawing/wrap_top_and_bottom', __dir__)
    end
  end
end