# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Math
      # Accent formatting properties
      #
      # Generated from OOXML schema: math.yml
      # Element: <m:accPr>
      class AccentProperties < Lutaml::Model::Serializable
          attribute :chr, Char
          attribute :ctrl_pr, ControlProperties

          xml do
            root 'accPr'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/math', 'm'
            mixed_content

            map_element 'chr', to: :chr, render_nil: false
            map_element 'ctrlPr', to: :ctrl_pr, render_nil: false
          end
      end
    end
  end
end
