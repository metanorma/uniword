# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    class W15DocId < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "docId"
        namespace Uniword::Ooxml::Namespaces::Word2012
        map_attribute "val", to: :val
      end
    end
  end
end
