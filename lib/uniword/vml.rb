# frozen_string_literal: true

# VML (Vector Markup Language) namespace
# Legacy drawing format for backward compatibility
# Namespace: urn:schemas-microsoft-com:vml
# Prefix: v:

module Uniword
  module Generated
    module Vml
      autoload :Curve, File.expand_path('vml/curve', __dir__)
      autoload :Fill, File.expand_path('vml/fill', __dir__)
      autoload :Formulas, File.expand_path('vml/formulas', __dir__)
      autoload :Group, File.expand_path('vml/group', __dir__)
      autoload :Handles, File.expand_path('vml/handles', __dir__)
      autoload :Imagedata, File.expand_path('vml/imagedata', __dir__)
      autoload :Line, File.expand_path('vml/line', __dir__)
      autoload :Oval, File.expand_path('vml/oval', __dir__)
      autoload :Path, File.expand_path('vml/path', __dir__)
      autoload :Polyline, File.expand_path('vml/polyline', __dir__)
      autoload :Rect, File.expand_path('vml/rect', __dir__)
      autoload :Shape, File.expand_path('vml/shape', __dir__)
      autoload :Shapetype, File.expand_path('vml/shapetype', __dir__)
      autoload :Stroke, File.expand_path('vml/stroke', __dir__)
      autoload :Textbox, File.expand_path('vml/textbox', __dir__)
      autoload :Wrap, File.expand_path('vml/wrap', __dir__)
    end
  end
end
