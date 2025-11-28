# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Math
      # Character specification
      #
      # Generated from OOXML schema: math.yml
      # Element: <m:chr>
      class Char < Lutaml::Model::Serializable
          attribute :val, String

          xml do
            root 'chr'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/math', 'm'

            map_attribute 'true', to: :val
          end
      end
    end
  end
end
