# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Math
      # Separator delimiter character
      #
      # Generated from OOXML schema: math.yml
      # Element: <m:sepChr>
      class SeparatorChar < Lutaml::Model::Serializable
          attribute :val, String

          xml do
            root 'sepChr'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/math', 'm'

            map_attribute 'true', to: :val
          end
      end
    end
  end
end
