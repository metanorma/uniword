# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    class RsidRoot < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "rsidRoot"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "val", to: :val
      end
    end
  end
end
