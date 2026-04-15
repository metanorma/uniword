# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # VML shape object
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:shape>
    class Shape < Lutaml::Model::Serializable
      attribute :id, :string
      attribute :type, :string
      attribute :style, :string

      xml do
        element "shape"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute "id", to: :id
        map_attribute "type", to: :type
        map_attribute "style", to: :style
      end
    end
  end
end
