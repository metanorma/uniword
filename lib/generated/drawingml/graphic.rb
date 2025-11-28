# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Graphic container element
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:graphic>
      class Graphic < Lutaml::Model::Serializable
          attribute :graphic_data, GraphicData

          xml do
            root 'graphic'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'
            mixed_content

            map_element 'graphicData', to: :graphic_data
          end
      end
    end
  end
end
