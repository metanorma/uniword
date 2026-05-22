# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    class MarRight < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "marRight"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "val", to: :val
      end
    end
  end
end
