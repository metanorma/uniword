# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Math
      # Matrix column formatting properties
      #
      # Generated from OOXML schema: math.yml
      # Element: <m:mcPr>
      class MatrixColumnProperties < Lutaml::Model::Serializable
          attribute :count, Integer
          attribute :column_jc, String

          xml do
            root 'mcPr'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/math', 'm'

            map_attribute 'val', to: :count
            map_attribute 'val', to: :column_jc
          end
      end
    end
  end
end
