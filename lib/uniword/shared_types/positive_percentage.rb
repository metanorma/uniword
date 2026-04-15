# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module SharedTypes
    # Positive percentage value
    #
    # Generated from OOXML schema: shared_types.yml
    # Element: <st:positive_percentage>
    class PositivePercentage < Lutaml::Model::Serializable
      attribute :val, :integer

      xml do
        element "positive_percentage"
        namespace Uniword::Ooxml::Namespaces::SharedTypes

        map_attribute "val", to: :val
      end
    end
  end
end
