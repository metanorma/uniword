# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Math
      # Box object (rectangular container)
      #
      # Generated from OOXML schema: math.yml
      # Element: <m:box>
      class Box < Lutaml::Model::Serializable
          attribute :properties, BoxProperties
          attribute :element, Element

          xml do
            element 'box'
            namespace Uniword::Ooxml::Namespaces::MathML
            mixed_content

            map_element 'boxPr', to: :properties, render_nil: false
            map_element 'e', to: :element
          end
      end
    end
end
