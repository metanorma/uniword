# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Linked style reference
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:link>
    class Link < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "link"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute "val", to: :val
      end
    end
  end
end
