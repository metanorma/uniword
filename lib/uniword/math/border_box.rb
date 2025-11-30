# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Math
    # Border box object
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:borderBox>
    class BorderBox < Lutaml::Model::Serializable
      attribute :properties, BorderBoxProperties
      attribute :element, Element

      xml do
        element 'borderBox'
        namespace Uniword::Ooxml::Namespaces::MathML
        mixed_content

        map_element 'borderBoxPr', to: :properties, render_nil: false
        map_element 'e', to: :element
      end
    end
  end
end
