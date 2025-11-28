# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Math
      # Matrix row
      #
      # Generated from OOXML schema: math.yml
      # Element: <m:mr>
      class MatrixRow < Lutaml::Model::Serializable
          attribute :elements, Element, collection: true, default: -> { [] }

          xml do
            root 'mr'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/math', 'm'
            mixed_content

            map_element 'e', to: :elements, render_nil: false
          end
      end
    end
  end
end
