# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Drawingml
      # Shape element
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:sp>
      class Shape < Lutaml::Model::Serializable
          attribute :nv_sp_pr, NonVisualShapeProperties
          attribute :sp_pr, ShapeProperties

          xml do
            element 'sp'
            namespace Uniword::Ooxml::Namespaces::DrawingML
            mixed_content

            map_element 'nvSpPr', to: :nv_sp_pr
            map_element 'spPr', to: :sp_pr
          end
      end
    end
end
