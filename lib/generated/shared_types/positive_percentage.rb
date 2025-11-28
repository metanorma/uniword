# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module SharedTypes
      # Positive percentage value
      #
      # Generated from OOXML schema: shared_types.yml
      # Element: <st:positive_percentage>
      class PositivePercentage < Lutaml::Model::Serializable
          attribute :val, :integer

          xml do
            root 'positive_percentage'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/sharedTypes', 'st'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
