# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Hyphenation zone width
    #
    # Element: <w:hyphenationZone>
    class HyphenationZone < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "hyphenationZone"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "val", to: :val
      end
    end
  end
end
