# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Math
      # Math run - text with formatting
      #
      # Generated from OOXML schema: math.yml
      # Element: <m:r>
      class MathRun < Lutaml::Model::Serializable
          attribute :properties, MathRunProperties
          attribute :text, String

          xml do
            root 'r'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/math', 'm'
            mixed_content

            map_element 'rPr', to: :properties, render_nil: false
            map_element 't', to: :text, render_nil: false
          end
      end
    end
  end
end
