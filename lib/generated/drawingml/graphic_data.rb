# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Graphic data holder with type URI
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:graphicData>
      class GraphicData < Lutaml::Model::Serializable
          attribute :uri, String

          xml do
            root 'graphicData'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'

            map_attribute 'true', to: :uri
          end
      end
    end
  end
end
