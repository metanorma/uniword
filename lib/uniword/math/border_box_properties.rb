# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Math
    # Border box formatting properties
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:borderBoxPr>
    class BorderBoxProperties < Lutaml::Model::Serializable
      attribute :hide_top, :string
      attribute :hide_bot, :string
      attribute :hide_left, :string
      attribute :hide_right, :string
      attribute :strike_h, :string
      attribute :strike_v, :string
      attribute :strike_bltr, :string
      attribute :strike_tlbr, :string
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
