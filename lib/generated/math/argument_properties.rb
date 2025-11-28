# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Math
      # Argument properties for math structures
      #
      # Generated from OOXML schema: math.yml
      # Element: <m:argPr>
      class ArgumentProperties < Lutaml::Model::Serializable
          attribute :arg_size, Integer

          xml do
            root 'argPr'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/math', 'm'

            map_attribute 'val', to: :arg_size
          end
      end
    end
  end
end
