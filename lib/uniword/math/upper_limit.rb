# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Math
      # Upper limit object
      #
      # Generated from OOXML schema: math.yml
      # Element: <m:limUpp>
      class UpperLimit < Lutaml::Model::Serializable
          attribute :properties, UpperLimitProperties
          attribute :element, Element
          attribute :lim, Lim

          xml do
            element 'limUpp'
            namespace Uniword::Ooxml::Namespaces::MathML
            mixed_content

            map_element 'limUppPr', to: :properties, render_nil: false
            map_element 'e', to: :element
            map_element 'lim', to: :lim
          end
      end
    end
end
