# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Next paragraph style
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:next>
    class Next < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "next"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute "val", to: :val
      end
    end
  end
end
