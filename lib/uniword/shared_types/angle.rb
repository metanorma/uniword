# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module SharedTypes
    # Angle measurement in 60,000ths of a degree
    #
    # Generated from OOXML schema: shared_types.yml
    # Element: <st:angle>
    class Angle < Lutaml::Model::Serializable
      attribute :val, :integer

      xml do
        element "angle"
        namespace Uniword::Ooxml::Namespaces::SharedTypes

        map_attribute "val", to: :val
      end
    end
  end
end
