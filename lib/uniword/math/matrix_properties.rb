# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Math
      # Matrix formatting properties
      #
      # Generated from OOXML schema: math.yml
      # Element: <m:mPr>
      class MatrixProperties < Lutaml::Model::Serializable
          attribute :base_jc, String
          attribute :plc_hide, String
          attribute :row_spacing_rule, Integer
          attribute :row_spacing, Integer
          attribute :column_gap_rule, Integer
          attribute :column_gap, Integer
          attribute :matrix_columns, MatrixColumns
          attribute :ctrl_pr, ControlProperties

          xml do
            element 'mPr'
            namespace Uniword::Ooxml::Namespaces::MathML
            mixed_content

            map_attribute 'val', to: :base_jc
            map_attribute 'val', to: :plc_hide
            map_attribute 'val', to: :row_spacing_rule
            map_attribute 'val', to: :row_spacing
            map_attribute 'val', to: :column_gap_rule
            map_attribute 'val', to: :column_gap
            map_element 'mcs', to: :matrix_columns, render_nil: false
            map_element 'ctrlPr', to: :ctrl_pr, render_nil: false
          end
      end
    end
end
