# frozen_string_literal: true

require 'lutaml/model'
require_relative 'math_simple_val'

module Uniword
  module Math
    # Equation array formatting properties
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:eqArrPr>
    class EquationArrayProperties < Lutaml::Model::Serializable
      attribute :base_jc, MathSimpleVal
      attribute :max_dist, MathSimpleVal
      attribute :obj_dist, MathSimpleVal
      attribute :row_spacing_rule, MathSimpleIntVal
      attribute :row_spacing, MathSimpleIntVal
      attribute :ctrl_pr, ControlProperties

      xml do
        element 'eqArrPr'
        namespace Uniword::Ooxml::Namespaces::MathML
        mixed_content

        map_element 'baseJc', to: :base_jc, render_nil: false
        map_element 'maxDist', to: :max_dist, render_nil: false
        map_element 'objDist', to: :obj_dist, render_nil: false
        map_element 'rSpRule', to: :row_spacing_rule, render_nil: false
        map_element 'rSp', to: :row_spacing, render_nil: false
        map_element 'ctrlPr', to: :ctrl_pr, render_nil: false
      end
    end
  end
end
