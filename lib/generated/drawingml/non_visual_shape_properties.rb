# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Non-visual shape properties
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:nvSpPr>
      class NonVisualShapeProperties < Lutaml::Model::Serializable
          attribute :c_nv_pr, NonVisualDrawingProperties

          xml do
            root 'nvSpPr'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'
            mixed_content

            map_element 'cNvPr', to: :c_nv_pr
          end
      end
    end
  end
end
