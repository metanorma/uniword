# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Math
    # Bar object (overbar, underbar)
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:bar>
    class Bar < Lutaml::Model::Serializable
      attribute :properties, BarProperties
      attribute :element, Element

      xml do
        element 'bar'
        namespace Uniword::Ooxml::Namespaces::MathML
        mixed_content

        map_element 'barPr', to: :properties, render_nil: false
        map_element 'e', to: :element
      end
    end
  end
end
