# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Math
      # Office Math paragraph - block-level math container
      #
      # Generated from OOXML schema: math.yml
      # Element: <m:oMathPara>
      class OMathPara < Lutaml::Model::Serializable
          attribute :para_properties, OMathParaProperties
          attribute :math_objects, OMath, collection: true, default: -> { [] }

          xml do
            root 'oMathPara'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/math', 'm'
            mixed_content

            map_element 'oMathParaPr', to: :para_properties, render_nil: false
            map_element 'oMath', to: :math_objects, render_nil: false
          end
      end
    end
  end
end
