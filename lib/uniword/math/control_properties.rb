# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Math
      # Control properties for math objects
      #
      # Generated from OOXML schema: math.yml
      # Element: <m:ctrlPr>
      class ControlProperties < Lutaml::Model::Serializable
          attribute :run_properties, String

          xml do
            element 'ctrlPr'
            namespace Uniword::Ooxml::Namespaces::MathML
            mixed_content

            map_element 'rPr', to: :run_properties, render_nil: false
          end
      end
    end
end
