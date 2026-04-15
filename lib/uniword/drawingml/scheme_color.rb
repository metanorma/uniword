# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Drawingml
    # Theme scheme color
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:schemeClr>
    class SchemeColor < Lutaml::Model::Serializable
      attribute :val, :string
      attribute :tint, Tint
      attribute :shade, Shade
      attribute :sat_mod, SaturationModulation
      attribute :lum_mod, LuminanceModulation
      attribute :alpha, Alpha
      attribute :alpha_mod, AlphaModulation
      attribute :alpha_off, AlphaOffset
      attribute :hue, Hue
      attribute :hue_mod, HueModulation
      attribute :hue_off, HueOffset

      xml do
        element "schemeClr"
        namespace Uniword::Ooxml::Namespaces::DrawingML
        ordered

        map_attribute "val", to: :val
        map_element "tint", to: :tint, render_nil: false
        map_element "shade", to: :shade, render_nil: false
        map_element "satMod", to: :sat_mod, render_nil: false
        map_element "lumMod", to: :lum_mod, render_nil: false
        map_element "alpha", to: :alpha, render_nil: false
        map_element "alphaMod", to: :alpha_mod, render_nil: false
        map_element "alphaOff", to: :alpha_off, render_nil: false
        map_element "hue", to: :hue, render_nil: false
        map_element "hueMod", to: :hue_mod, render_nil: false
        map_element "hueOff", to: :hue_off, render_nil: false
      end
    end
  end
end
