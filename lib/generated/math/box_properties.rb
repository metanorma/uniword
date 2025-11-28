# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Math
      # Box formatting properties
      #
      # Generated from OOXML schema: math.yml
      # Element: <m:boxPr>
      class BoxProperties < Lutaml::Model::Serializable
          attribute :opEmu, String
          attribute :no_break, String
          attribute :diff, String
          attribute :brk, MathBreak
          attribute :aln, String
          attribute :ctrl_pr, ControlProperties

          xml do
            root 'boxPr'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/math', 'm'
            mixed_content

            map_attribute 'val', to: :opEmu
            map_attribute 'val', to: :no_break
            map_attribute 'val', to: :diff
            map_element 'brk', to: :brk, render_nil: false
            map_attribute 'val', to: :aln
            map_element 'ctrlPr', to: :ctrl_pr, render_nil: false
          end
      end
    end
  end
end
