# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Shape element
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:sp>
      class Shape < Lutaml::Model::Serializable
          attribute :nv_sp_pr, NonVisualShapeProperties
          attribute :sp_pr, ShapeProperties

          xml do
            root 'sp'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'
            mixed_content

            map_element 'nvSpPr', to: :nv_sp_pr
            map_element 'spPr', to: :sp_pr
          end
      end
    end
  end
end
