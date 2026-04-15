# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Object extent dimensions
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:extent>
    class Extent < Lutaml::Model::Serializable
      attribute :cx, :integer
      attribute :cy, :integer

      xml do
        element "extent"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute "cx", to: :cx
        map_attribute "cy", to: :cy
      end
    end
  end
end
