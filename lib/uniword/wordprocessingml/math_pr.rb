# frozen_string_literal: true

require "lutaml/model"
require_relative "math_font"
require_relative "brk_bin"
require_relative "brk_bin_sub"
require_relative "small_frac"
require_relative "disp_def"
require_relative "l_margin"
require_relative "r_margin"
require_relative "def_jc"
require_relative "wrap_indent"
require_relative "int_lim"
require_relative "nary_lim"

module Uniword
  module Wordprocessingml
    class MathPr < Lutaml::Model::Serializable
      attribute :math_font, MathFont
      attribute :brk_bin, BrkBin
      attribute :brk_bin_sub, BrkBinSub
      attribute :small_frac, SmallFrac
      attribute :disp_def, DispDef
      attribute :l_margin, LMargin
      attribute :r_margin, RMargin
      attribute :def_jc, DefJc
      attribute :wrap_indent, WrapIndent
      attribute :int_lim, IntLim
      attribute :nary_lim, NaryLim

      xml do
        element "mathPr"
        namespace Uniword::Ooxml::Namespaces::MathML
        mixed_content
        map_element "mathFont", to: :math_font, render_nil: false
        map_element "brkBin", to: :brk_bin, render_nil: false
        map_element "brkBinSub", to: :brk_bin_sub, render_nil: false
        map_element "smallFrac", to: :small_frac, render_nil: false
        map_element "dispDef", to: :disp_def, render_nil: false
        map_element "lMargin", to: :l_margin, render_nil: false
        map_element "rMargin", to: :r_margin, render_nil: false
        map_element "defJc", to: :def_jc, render_nil: false
        map_element "wrapIndent", to: :wrap_indent, render_nil: false
        map_element "intLim", to: :int_lim, render_nil: false
        map_element "naryLim", to: :nary_lim, render_nil: false
      end
    end
  end
end
