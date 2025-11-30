# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Math
      # Radical object (square root, nth root)
      #
      # Generated from OOXML schema: math.yml
      # Element: <m:rad>
      class Radical < Lutaml::Model::Serializable
          attribute :properties, RadicalProperties
          attribute :degree, Degree
          attribute :element, Element

          xml do
            element 'rad'
            namespace Uniword::Ooxml::Namespaces::MathML
            mixed_content

            map_element 'radPr', to: :properties, render_nil: false
            map_element 'deg', to: :degree, render_nil: false
            map_element 'e', to: :element
          end
      end
    end
end
