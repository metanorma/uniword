# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Graphic data holder with type URI
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:graphicData>
    class GraphicData < Lutaml::Model::Serializable
      attribute :uri, :string

      xml do
        element 'graphicData'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute 'uri', to: :uri
      end
    end
  end
end
