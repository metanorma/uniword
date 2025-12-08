# frozen_string_literal: true

# VML namespace module
# This file explicitly autoloads all VML classes
# Using explicit autoload instead of dynamic Dir[] for maintainability
#
# VML (Vector Markup Language) - Legacy drawing format for backward compatibility
# Namespace: urn:schemas-microsoft-com:vml
# Prefix: v:

module Uniword
  module Generated
    module Vml
      # Autoload all VML classes (18)
      autoload :Curve, 'uniword/vml/curve'
      autoload :Fill, 'uniword/vml/fill'
      autoload :Formula, 'uniword/vml/formula'
      autoload :Formulas, 'uniword/vml/formulas'
      autoload :Group, 'uniword/vml/group'
      autoload :Handle, 'uniword/vml/handle'
      autoload :Handles, 'uniword/vml/handles'
      autoload :Imagedata, 'uniword/vml/imagedata'
      autoload :Line, 'uniword/vml/line'
      autoload :Oval, 'uniword/vml/oval'
      autoload :Path, 'uniword/vml/path'
      autoload :Polyline, 'uniword/vml/polyline'
      autoload :Rect, 'uniword/vml/rect'
      autoload :Shape, 'uniword/vml/shape'
      autoload :Shapetype, 'uniword/vml/shapetype'
      autoload :Stroke, 'uniword/vml/stroke'
      autoload :Textbox, 'uniword/vml/textbox'
      autoload :Wrap, 'uniword/vml/wrap'
    end
  end
end