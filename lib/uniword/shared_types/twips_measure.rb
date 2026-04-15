# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module SharedTypes
    # Measurement in twips (1/20th of a point)
    #
    # Generated from OOXML schema: shared_types.yml
    # Element: <st:twips_measure>
    class TwipsMeasure < Lutaml::Model::Serializable
      attribute :val, :integer

      xml do
        element "twips_measure"
        namespace Uniword::Ooxml::Namespaces::SharedTypes

        map_attribute "val", to: :val
      end
    end
  end
end
