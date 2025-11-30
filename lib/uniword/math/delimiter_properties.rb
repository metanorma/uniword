# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Math
      # Delimiter formatting properties
      #
      # Generated from OOXML schema: math.yml
      # Element: <m:dPr>
      class DelimiterProperties < Lutaml::Model::Serializable
          attribute :begin_char, BeginChar
          attribute :end_char, EndChar
          attribute :separator_char, SeparatorChar
          attribute :grow, String
          attribute :shape, String
          attribute :ctrl_pr, ControlProperties

          xml do
            element 'dPr'
            namespace Uniword::Ooxml::Namespaces::MathML
            mixed_content

            map_element 'begChr', to: :begin_char, render_nil: false
            map_element 'endChr', to: :end_char, render_nil: false
            map_element 'sepChr', to: :separator_char, render_nil: false
            map_attribute 'val', to: :grow
            map_attribute 'val', to: :shape
            map_element 'ctrlPr', to: :ctrl_pr, render_nil: false
          end
      end
    end
end
