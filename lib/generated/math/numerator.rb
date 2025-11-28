# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Math
      # Fraction numerator
      #
      # Generated from OOXML schema: math.yml
      # Element: <m:num>
      class Numerator < Lutaml::Model::Serializable
          attribute :arg_properties, ArgumentProperties
          attribute :elements, String, collection: true, default: -> { [] }

          xml do
            root 'num'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/math', 'm'
            mixed_content

            map_element 'argPr', to: :arg_properties, render_nil: false
            map_element '*', to: :elements, render_nil: false
          end
      end
    end
  end
end
