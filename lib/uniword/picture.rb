# frozen_string_literal: true

# Picture Namespace Autoload Index
# Generated from: config/ooxml/schemas/picture.yml
# Namespace: http://schemas.openxmlformats.org/drawingml/2006/picture
# Prefix: pic
# Total classes: 10

module Uniword
  module Picture
    # Autoload all Picture classes
    autoload :Picture, File.expand_path('picture/picture', __dir__)
    autoload :NonVisualPictureProperties,
             File.expand_path('picture/non_visual_picture_properties', __dir__)
    autoload :NonVisualPictureDrawingProperties,
             File.expand_path('picture/non_visual_picture_drawing_properties', __dir__)
    autoload :PictureLocks, File.expand_path('picture/picture_locks', __dir__)
    autoload :PictureBlipFill, File.expand_path('picture/picture_blip_fill', __dir__)
    autoload :PictureSourceRect, File.expand_path('picture/picture_source_rect', __dir__)
    autoload :PictureStretch, File.expand_path('picture/picture_stretch', __dir__)
    autoload :FillRect, File.expand_path('picture/fill_rect', __dir__)
    autoload :Tile, File.expand_path('picture/tile', __dir__)
    autoload :PictureShapeProperties, File.expand_path('picture/picture_shape_properties', __dir__)
  end
end
