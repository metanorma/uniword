# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Math
    # Function name (e.g., sin, cos, log)
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:fName>
    class FunctionName < Lutaml::Model::Serializable
      # Pattern 0: Attributes BEFORE xml mappings
      attribute :arg_properties, ArgumentProperties
      attribute :runs, MathRun, collection: true, default: -> { [] }

      xml do
        element 'fName'
        namespace Uniword::Ooxml::Namespaces::MathML
        mixed_content

        map_element 'argPr', to: :arg_properties, render_nil: false
        map_element 'r', to: :runs, render_nil: false
      end
    end
  end
end
