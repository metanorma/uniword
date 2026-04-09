# frozen_string_literal: true

# GVML (Graphical Variant Markup Language) namespace module
# This file explicitly autoloads all GVML classes
#
# GVML - Legacy-compatible drawing shapes, connectors, pictures, and groups
# Namespace: http://schemas.openxmlformats.org/drawingml/2006/main
# Prefix: a:

module Uniword
  module Drawingml
    # GVML classes (12)
    autoload :GvmlUseShapeRectangle, 'uniword/drawingml/gvml_use_shape_rectangle'
    autoload :GvmlTextShape, 'uniword/drawingml/gvml_text_shape'
    autoload :GvmlShapeNonVisual, 'uniword/drawingml/gvml_shape_non_visual'
    autoload :GvmlShape, 'uniword/drawingml/gvml_shape'
    autoload :GvmlConnectorNonVisual, 'uniword/drawingml/gvml_connector_non_visual'
    autoload :GvmlConnector, 'uniword/drawingml/gvml_connector'
    autoload :GvmlPictureNonVisual, 'uniword/drawingml/gvml_picture_non_visual'
    autoload :GvmlPicture, 'uniword/drawingml/gvml_picture'
    autoload :GvmlGraphicFrameNonVisual, 'uniword/drawingml/gvml_graphic_frame_non_visual'
    autoload :GvmlGraphicalObjectFrame, 'uniword/drawingml/gvml_graphical_object_frame'
    autoload :GvmlGroupShapeNonVisual, 'uniword/drawingml/gvml_group_shape_non_visual'
    autoload :GvmlGroupShape, 'uniword/drawingml/gvml_group_shape'
  end
end
