# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Math
    # Fraction numerator
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:num>
    class Numerator < Lutaml::Model::Serializable
      # Pattern 0: Attributes BEFORE xml mappings
      attribute :arg_properties, ArgumentProperties
      attribute :runs, MathRun, collection: true, default: -> { [] }

      xml do
        element 'num'
        namespace Uniword::Ooxml::Namespaces::MathML
        mixed_content

        map_element 'argPr', to: :arg_properties, render_nil: false
        map_element 'r', to: :runs, render_nil: false
      end
    end
  end
end
