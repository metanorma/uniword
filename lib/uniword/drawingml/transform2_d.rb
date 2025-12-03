# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # 2D transformation
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:xfrm>
    class Transform2D < Lutaml::Model::Serializable
      attribute :off, Offset
      attribute :ext, Extents

      xml do
        element 'xfrm'
        namespace Uniword::Ooxml::Namespaces::DrawingML
        mixed_content

        map_element 'off', to: :off, render_nil: false
        map_element 'ext', to: :ext, render_nil: false
      end
    end
  end
end
