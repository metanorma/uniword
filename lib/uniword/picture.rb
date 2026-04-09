# frozen_string_literal: true

# Picture Namespace Autoload Index
# Generated from: config/ooxml/schemas/picture.yml
# Namespace: http://schemas.openxmlformats.org/drawingml/2006/picture
# Prefix: pic
# Total classes: 10

module Uniword
  module Picture
    # Autoload all Picture classes
    autoload :Picture, "#{__dir__}/picture/picture"
    autoload :NonVisualPictureProperties,
             "#{__dir__}/picture/non_visual_picture_properties"
    autoload :NonVisualPictureDrawingProperties,
             "#{__dir__}/picture/non_visual_picture_drawing_properties"
    autoload :PictureLocks, "#{__dir__}/picture/picture_locks"
    autoload :PictureBlipFill, "#{__dir__}/picture/picture_blip_fill"
    autoload :PictureSourceRect, "#{__dir__}/picture/picture_source_rect"
    autoload :PictureStretch, "#{__dir__}/picture/picture_stretch"
    autoload :FillRect, "#{__dir__}/picture/fill_rect"
    autoload :Tile, "#{__dir__}/picture/tile"
    autoload :PictureShapeProperties, "#{__dir__}/picture/picture_shape_properties"
  end
end
