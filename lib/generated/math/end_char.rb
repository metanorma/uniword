# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Math
      # Ending delimiter character
      #
      # Generated from OOXML schema: math.yml
      # Element: <m:endChr>
      class EndChar < Lutaml::Model::Serializable
          attribute :val, String

          xml do
            root 'endChr'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/math', 'm'

            map_attribute 'true', to: :val
          end
      end
    end
  end
end
