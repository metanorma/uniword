# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module SharedTypes
      # Percentage value
      #
      # Generated from OOXML schema: shared_types.yml
      # Element: <st:percent_value>
      class PercentValue < Lutaml::Model::Serializable
          attribute :val, :integer

          xml do
            root 'percent_value'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/sharedTypes', 'st'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
