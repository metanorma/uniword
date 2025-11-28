# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module SharedTypes
      # Decimal number type
      #
      # Generated from OOXML schema: shared_types.yml
      # Element: <st:decimal_number>
      class DecimalNumber < Lutaml::Model::Serializable
          attribute :val, :integer

          xml do
            root 'decimal_number'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/sharedTypes', 'st'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
