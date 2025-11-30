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
      attribute :brk_bin, String
      attribute :brk_bin_sub, String
      attribute :small_frac, String
      attribute :disp_def, String
      attribute :lMargin, Integer
      attribute :rMargin, Integer
      attribute :def_jc, String
      attribute :pre_sp, Integer
      attribute :post_sp, Integer
      attribute :inter_sp, Integer
      attribute :intra_sp, Integer
      attribute :wrap_indent, Integer
      attribute :wrap_right, String
      attribute :int_lim, String
      attribute :n_ary_lim, String

      xml do
        element 'mathPr'
        namespace Uniword::Ooxml::Namespaces::MathML
        mixed_content

        map_element 'mathFont', to: :math_font, render_nil: false
        map_attribute 'val', to: :brk_bin
        map_attribute 'val', to: :brk_bin_sub
        map_attribute 'val', to: :small_frac
        map_attribute 'val', to: :disp_def
        map_attribute 'val', to: :lMargin
        map_attribute 'val', to: :rMargin
        map_attribute 'val', to: :def_jc
        map_attribute 'val', to: :pre_sp
        map_attribute 'val', to: :post_sp
        map_attribute 'val', to: :inter_sp
        map_attribute 'val', to: :intra_sp
        map_attribute 'val', to: :wrap_indent
        map_attribute 'val', to: :wrap_right
        map_attribute 'val', to: :int_lim
        map_attribute 'val', to: :n_ary_lim
      end
    end
  end
end
