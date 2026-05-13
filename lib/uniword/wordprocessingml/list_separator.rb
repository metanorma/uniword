# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    class ListSeparator < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "listSeparator"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "val", to: :val
      end
    end
  end
end
