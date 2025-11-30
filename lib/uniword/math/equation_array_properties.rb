# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Math
    # Equation array formatting properties
    #
    # Generated from OOXML schema: math.yml
    # Element: <m:eqArrPr>
    class EquationArrayProperties < Lutaml::Model::Serializable
      attribute :base_jc, String
      attribute :max_dist, String
      attribute :obj_dist, String
      attribute :row_spacing_rule, Integer
      attribute :row_spacing, Integer
      attribute :ctrl_pr, ControlProperties

      xml do
        element 'eqArrPr'
        namespace Uniword::Ooxml::Namespaces::MathML
        mixed_content

        map_attribute 'val', to: :base_jc
        map_attribute 'val', to: :max_dist
        map_attribute 'val', to: :obj_dist
        map_attribute 'val', to: :row_spacing_rule
        map_attribute 'val', to: :row_spacing
        map_element 'ctrlPr', to: :ctrl_pr, render_nil: false
      end
    end
  end
end
