# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Math
      # Lower limit formatting properties
      #
      # Generated from OOXML schema: math.yml
      # Element: <m:limLowPr>
      class LowerLimitProperties < Lutaml::Model::Serializable
          attribute :ctrl_pr, ControlProperties

          xml do
            root 'limLowPr'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/math', 'm'
            mixed_content

            map_element 'ctrlPr', to: :ctrl_pr, render_nil: false
          end
      end
    end
  end
end
