# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Math
      # Accent object (hat, tilde, bar)
      #
      # Generated from OOXML schema: math.yml
      # Element: <m:acc>
      class Accent < Lutaml::Model::Serializable
          attribute :properties, AccentProperties
          attribute :element, Element

          xml do
            element 'acc'
            namespace Uniword::Ooxml::Namespaces::MathML
            mixed_content

            map_element 'accPr', to: :properties, render_nil: false
            map_element 'e', to: :element
          end
      end
    end
end
