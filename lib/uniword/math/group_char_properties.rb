# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Math
      # Group character formatting properties
      #
      # Generated from OOXML schema: math.yml
      # Element: <m:groupChrPr>
      class GroupCharProperties < Lutaml::Model::Serializable
          attribute :chr, Char
          attribute :pos, String
          attribute :vert_jc, String
          attribute :ctrl_pr, ControlProperties

          xml do
            element 'groupChrPr'
            namespace Uniword::Ooxml::Namespaces::MathML
            mixed_content

            map_element 'chr', to: :chr, render_nil: false
            map_attribute 'val', to: :pos
            map_attribute 'val', to: :vert_jc
            map_element 'ctrlPr', to: :ctrl_pr, render_nil: false
          end
      end
    end
end
