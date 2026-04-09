# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Math
    # Equation array (system of equations)
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:eqArr>
    class EquationArray < Lutaml::Model::Serializable
      attribute :properties, EquationArrayProperties
      attribute :elements, Element, collection: true, initialize_empty: true

      xml do
        element 'eqArr'
        namespace Uniword::Ooxml::Namespaces::MathML
        mixed_content

        map_element 'eqArrPr', to: :properties, render_nil: false
        map_element 'e', to: :elements, render_nil: false
      end
    end
  end
end
