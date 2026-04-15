# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Multilevel type
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:multiLevelType>
    class MultiLevelType < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "multiLevelType"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute "val", to: :val
      end
    end
  end
end
