# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Math
      # Bar formatting properties
      #
      # Generated from OOXML schema: math.yml
      # Element: <m:barPr>
      class BarProperties < Lutaml::Model::Serializable
          attribute :pos, String
          attribute :ctrl_pr, ControlProperties

          xml do
            root 'barPr'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/math', 'm'
            mixed_content

            map_attribute 'val', to: :pos
            map_element 'ctrlPr', to: :ctrl_pr, render_nil: false
          end
      end
    end
  end
end
