# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Math
      # N-ary operator (sum, integral, product)
      #
      # Generated from OOXML schema: math.yml
      # Element: <m:nary>
      class Nary < Lutaml::Model::Serializable
          attribute :properties, NaryProperties
          attribute :sub, Sub
          attribute :sup, Sup
          attribute :element, Element

          xml do
            element 'nary'
            namespace Uniword::Ooxml::Namespaces::MathML
            mixed_content

            map_element 'naryPr', to: :properties, render_nil: false
            map_element 'sub', to: :sub, render_nil: false
            map_element 'sup', to: :sup, render_nil: false
            map_element 'e', to: :element
          end
      end
    end
end
