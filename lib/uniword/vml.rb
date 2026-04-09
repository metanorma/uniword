# frozen_string_literal: true

# VML namespace module
# This file explicitly autoloads all VML classes
# Using explicit autoload instead of dynamic Dir[] for maintainability
#
# VML (Vector Markup Language) - Legacy drawing format for backward compatibility
# Namespace: urn:schemas-microsoft-com:vml
# Prefix: v:

module Uniword
  module Vml
    # Autoload all VML classes (23)
    autoload :Arc, 'uniword/vml/arc'
    autoload :Background, 'uniword/vml/background'
    autoload :Curve, 'uniword/vml/curve'
    autoload :Fill, 'uniword/vml/fill'
    autoload :Formula, 'uniword/vml/formula'
    autoload :Formulas, 'uniword/vml/formulas'
    autoload :Group, 'uniword/vml/group'
    autoload :Handle, 'uniword/vml/handle'
    autoload :Handles, 'uniword/vml/handles'
    autoload :Image, 'uniword/vml/image'
    autoload :Imagedata, 'uniword/vml/imagedata'
    autoload :Line, 'uniword/vml/line'
    autoload :Oval, 'uniword/vml/oval'
    autoload :Path, 'uniword/vml/path'
    autoload :Polyline, 'uniword/vml/polyline'
    autoload :Rect, 'uniword/vml/rect'
    autoload :Roundrect, 'uniword/vml/roundrect'
    autoload :Shadow, 'uniword/vml/shadow'
    autoload :Shape, 'uniword/vml/shape'
    autoload :Shapetype, 'uniword/vml/shapetype'
    autoload :Stroke, 'uniword/vml/stroke'
    autoload :Textbox, 'uniword/vml/textbox'
    autoload :TextPath, 'uniword/vml/textpath'
    autoload :Wrap, 'uniword/vml/wrap'
  end
end
