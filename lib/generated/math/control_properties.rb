# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Math
      # Control properties for math objects
      #
      # Generated from OOXML schema: math.yml
      # Element: <m:ctrlPr>
      class ControlProperties < Lutaml::Model::Serializable
          attribute :run_properties, String

          xml do
            root 'ctrlPr'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/math', 'm'
            mixed_content

            map_element 'rPr', to: :run_properties, render_nil: false
          end
      end
    end
  end
end
