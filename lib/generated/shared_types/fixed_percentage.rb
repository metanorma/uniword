# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module SharedTypes
      # Fixed percentage type (constrained range)
      #
      # Generated from OOXML schema: shared_types.yml
      # Element: <st:fixed_percentage>
      class FixedPercentage < Lutaml::Model::Serializable
          attribute :val, :integer

          xml do
            root 'fixed_percentage'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/sharedTypes', 'st'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
