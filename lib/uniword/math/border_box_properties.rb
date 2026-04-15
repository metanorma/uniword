# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Math
    # Border box formatting properties
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:borderBoxPr>
    class BorderBoxProperties < Lutaml::Model::Serializable
      attribute :hide_top, MathSimpleVal
      attribute :hide_bot, MathSimpleVal
      attribute :hide_left, MathSimpleVal
      attribute :hide_right, MathSimpleVal
      attribute :strike_h, MathSimpleVal
      attribute :strike_v, MathSimpleVal
      attribute :strike_bltr, MathSimpleVal
      attribute :strike_tlbr, MathSimpleVal
      attribute :ctrl_pr, ControlProperties

      xml do
        element "borderBoxPr"
        namespace Uniword::Ooxml::Namespaces::MathML
        mixed_content

        map_element "hideTop", to: :hide_top, render_nil: false
        map_element "hideBot", to: :hide_bot, render_nil: false
        map_element "hideLeft", to: :hide_left, render_nil: false
        map_element "hideRight", to: :hide_right, render_nil: false
        map_element "strikeH", to: :strike_h, render_nil: false
        map_element "strikeV", to: :strike_v, render_nil: false
        map_element "strikeBLTR", to: :strike_bltr, render_nil: false
        map_element "strikeTLBR", to: :strike_tlbr, render_nil: false
        map_element "ctrlPr", to: :ctrl_pr, render_nil: false
      end
    end
  end
end
