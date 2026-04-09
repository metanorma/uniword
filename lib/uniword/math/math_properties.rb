# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Math
    # Document-level math properties
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:mathPr>
    class MathProperties < Lutaml::Model::Serializable
      attribute :math_font, MathFont
      attribute :brk_bin, MathSimpleVal
      attribute :brk_bin_sub, MathSimpleVal
      attribute :small_frac, MathSimpleVal
      attribute :disp_def, MathSimpleVal
      attribute :lMargin, MathSimpleIntVal
      attribute :rMargin, MathSimpleIntVal
      attribute :def_jc, MathSimpleVal
      attribute :pre_sp, MathSimpleIntVal
      attribute :post_sp, MathSimpleIntVal
      attribute :inter_sp, MathSimpleIntVal
      attribute :intra_sp, MathSimpleIntVal
      attribute :wrap_indent, MathSimpleIntVal
      attribute :wrap_right, MathSimpleVal
      attribute :int_lim, MathSimpleVal
      attribute :n_ary_lim, MathSimpleVal

      xml do
        element 'mathPr'
        namespace Uniword::Ooxml::Namespaces::MathML
        mixed_content

        map_element 'mathFont', to: :math_font, render_nil: false
        map_element 'brkBin', to: :brk_bin, render_nil: false
        map_element 'brkBinSub', to: :brk_bin_sub, render_nil: false
        map_element 'smallFrac', to: :small_frac, render_nil: false
        map_element 'dispDef', to: :disp_def, render_nil: false
        map_element 'lMargin', to: :lMargin, render_nil: false
        map_element 'rMargin', to: :rMargin, render_nil: false
        map_element 'defJc', to: :def_jc, render_nil: false
        map_element 'preSp', to: :pre_sp, render_nil: false
        map_element 'postSp', to: :post_sp, render_nil: false
        map_element 'interSp', to: :inter_sp, render_nil: false
        map_element 'intraSp', to: :intra_sp, render_nil: false
        map_element 'wrapIndent', to: :wrap_indent, render_nil: false
        map_element 'wrapRight', to: :wrap_right, render_nil: false
        map_element 'intLim', to: :int_lim, render_nil: false
        map_element 'naryLim', to: :n_ary_lim, render_nil: false
      end
    end
  end
end
