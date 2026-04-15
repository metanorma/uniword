# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module SharedTypes
    # Decimal number type
    #
    # Generated from OOXML schema: shared_types.yml
    # Element: <st:decimal_number>
    class DecimalNumber < Lutaml::Model::Serializable
      attribute :val, :integer

      xml do
        element "decimal_number"
        namespace Uniword::Ooxml::Namespaces::SharedTypes

        map_attribute "val", to: :val
      end
    end
  end
end
