# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    class DivBorder < Lutaml::Model::Serializable
      attribute :val, :string
      attribute :sz, :string
      attribute :space, :string
      attribute :color, :string

      xml do
        element "border"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "val", to: :val
        map_attribute "sz", to: :sz
        map_attribute "space", to: :space
        map_attribute "color", to: :color
      end
    end
  end
end
