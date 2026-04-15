# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module SharedTypes
    # String value type
    #
    # Generated from OOXML schema: shared_types.yml
    # Element: <st:string>
    class StringType < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "string"
        namespace Uniword::Ooxml::Namespaces::SharedTypes

        map_attribute "val", to: :val
      end
    end
  end
end
