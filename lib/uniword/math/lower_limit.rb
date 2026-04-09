# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Math
    # Lower limit object
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:limLow>
    class LowerLimit < Lutaml::Model::Serializable
      attribute :properties, LowerLimitProperties
      attribute :element, Element
      attribute :lim, Lim

      xml do
        element 'limLow'
        namespace Uniword::Ooxml::Namespaces::MathML
        mixed_content

        map_element 'limLowPr', to: :properties, render_nil: false
        map_element 'e', to: :element
        map_element 'lim', to: :lim
      end
    end
  end
end
