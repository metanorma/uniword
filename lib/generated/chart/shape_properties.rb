# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Chart
      # Shape properties reference (DrawingML)
      #
      # Generated from OOXML schema: chart.yml
      # Element: <c:spPr>
      class ShapeProperties < Lutaml::Model::Serializable
          attribute :content, :string

          xml do
            root 'spPr'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/chart', 'c'

            map_element '', to: :content, render_nil: false
          end
      end
    end
  end
end
