# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    class BrkBin < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "brkBin"
        namespace Uniword::Ooxml::Namespaces::MathML
        map_attribute "val", to: :val
      end
    end
  end
end
