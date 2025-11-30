# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Math
      # Border box formatting properties
      #
      # Generated from OOXML schema: math.yml
      # Element: <m:borderBoxPr>
      class BorderBoxProperties < Lutaml::Model::Serializable
          attribute :hide_top, String
          attribute :hide_bot, String
          attribute :hide_left, String
          attribute :hide_right, String
          attribute :strike_h, String
          attribute :strike_v, String
          attribute :strike_bltr, String
          attribute :strike_tlbr, String
          attribute :ctrl_pr, ControlProperties

          xml do
            element 'borderBoxPr'
            namespace Uniword::Ooxml::Namespaces::MathML
            mixed_content

            map_attribute 'val', to: :hide_top
            map_attribute 'val', to: :hide_bot
            map_attribute 'val', to: :hide_left
            map_attribute 'val', to: :hide_right
            map_attribute 'val', to: :strike_h
            map_attribute 'val', to: :strike_v
            map_attribute 'val', to: :strike_bltr
            map_attribute 'val', to: :strike_tlbr
            map_element 'ctrlPr', to: :ctrl_pr, render_nil: false
          end
      end
    end
end
