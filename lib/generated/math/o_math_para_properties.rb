# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Math
      # Math paragraph properties
      #
      # Generated from OOXML schema: math.yml
      # Element: <m:oMathParaPr>
      class OMathParaProperties < Lutaml::Model::Serializable
          attribute :justification, String

          xml do
            root 'oMathParaPr'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/math', 'm'

            map_attribute 'val', to: :justification
          end
      end
    end
  end
end
