# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Math
      # Fraction formatting properties
      #
      # Generated from OOXML schema: math.yml
      # Element: <m:fPr>
      class FractionProperties < Lutaml::Model::Serializable
          attribute :type, String
          attribute :ctrl_pr, ControlProperties

          xml do
            root 'fPr'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/math', 'm'
            mixed_content

            map_attribute 'val', to: :type
            map_element 'ctrlPr', to: :ctrl_pr, render_nil: false
          end
      end
    end
  end
end
