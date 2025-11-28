# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Math
      # Upper limit formatting properties
      #
      # Generated from OOXML schema: math.yml
      # Element: <m:limUppPr>
      class UpperLimitProperties < Lutaml::Model::Serializable
          attribute :ctrl_pr, ControlProperties

          xml do
            root 'limUppPr'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/math', 'm'
            mixed_content

            map_element 'ctrlPr', to: :ctrl_pr, render_nil: false
          end
      end
    end
  end
end
