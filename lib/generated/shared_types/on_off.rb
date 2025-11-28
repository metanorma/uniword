# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module SharedTypes
      # Boolean on/off type used throughout OOXML
      #
      # Generated from OOXML schema: shared_types.yml
      # Element: <st:on_off>
      class OnOff < Lutaml::Model::Serializable
          attribute :val, :boolean

          xml do
            root 'on_off'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/sharedTypes', 'st'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
