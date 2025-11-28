# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module SharedTypes
      # Hexadecimal color value (RGB)
      #
      # Generated from OOXML schema: shared_types.yml
      # Element: <st:hex_color>
      class HexColor < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            root 'hex_color'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/sharedTypes', 'st'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
