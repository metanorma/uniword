# frozen_string_literal: true

require 'lutaml/model'
require_relative 'math_simple_val'

module Uniword
  module Math
    # Group character formatting properties
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:groupChrPr>
    class GroupCharProperties < Lutaml::Model::Serializable
      attribute :chr, Char
      attribute :pos, MathSimpleVal
      attribute :vert_jc, MathSimpleVal
      attribute :ctrl_pr, ControlProperties

      xml do
        element 'groupChrPr'
        namespace Uniword::Ooxml::Namespaces::MathML
        mixed_content

        map_element 'chr', to: :chr, render_nil: false
        map_element 'pos', to: :pos, render_nil: false
        map_element 'vertJc', to: :vert_jc, render_nil: false
        map_element 'ctrlPr', to: :ctrl_pr, render_nil: false
      end
    end
  end
end
