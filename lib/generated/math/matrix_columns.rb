# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Math
      # Matrix column properties
      #
      # Generated from OOXML schema: math.yml
      # Element: <m:mcs>
      class MatrixColumns < Lutaml::Model::Serializable
          attribute :columns, MatrixColumn, collection: true, default: -> { [] }

          xml do
            root 'mcs'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/math', 'm'
            mixed_content

            map_element 'mc', to: :columns, render_nil: false
          end
      end
    end
  end
end
