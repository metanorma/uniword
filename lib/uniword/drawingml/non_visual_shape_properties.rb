# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Drawingml
      # Non-visual shape properties
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:nvSpPr>
      class NonVisualShapeProperties < Lutaml::Model::Serializable
          attribute :c_nv_pr, NonVisualDrawingProperties

          xml do
            element 'nvSpPr'
            namespace Uniword::Ooxml::Namespaces::DrawingML
            mixed_content

            map_element 'cNvPr', to: :c_nv_pr
          end
      end
    end
end
