# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module SharedTypes
    # Percentage value
    #
    # Generated from OOXML schema: shared_types.yml
    # Element: <st:percent_value>
    class PercentValue < Lutaml::Model::Serializable
      attribute :val, :integer

      xml do
        element 'percent_value'
        namespace Uniword::Ooxml::Namespaces::SharedTypes

        map_attribute 'val', to: :val
      end
    end
  end
end
