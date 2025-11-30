# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Adjustment value list
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:avLst>
    class AdjustValueList < Lutaml::Model::Serializable
      attribute :guides, GeometryGuide, collection: true, default: -> { [] }

      xml do
        element 'avLst'
        namespace Uniword::Ooxml::Namespaces::DrawingML
        mixed_content

        map_element 'gd', to: :guides, render_nil: false
      end
    end
  end
end
