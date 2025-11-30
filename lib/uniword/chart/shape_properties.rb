# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Chart
    # Shape properties reference (DrawingML)
    #
    # Generated from OOXML schema: chart.yml
    # Element: <c:spPr>
    class ShapeProperties < Lutaml::Model::Serializable
      attribute :content, :string

      xml do
        element 'spPr'
        namespace Uniword::Ooxml::Namespaces::Chart

        map_element '', to: :content, render_nil: false
      end
    end
  end
end
