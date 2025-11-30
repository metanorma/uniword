# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Math
      # Office Math paragraph - block-level math container
      #
      # Generated from OOXML schema: math.yml
      # Element: <m:oMathPara>
      class OMathPara < Lutaml::Model::Serializable
          attribute :para_properties, OMathParaProperties
          attribute :math_objects, OMath, collection: true, default: -> { [] }

          xml do
            element 'oMathPara'
            namespace Uniword::Ooxml::Namespaces::MathML
            mixed_content

            map_element 'oMathParaPr', to: :para_properties, render_nil: false
            map_element 'oMath', to: :math_objects, render_nil: false
          end
      end
    end
end
