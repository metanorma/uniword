# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    class ProofState < Lutaml::Model::Serializable
      attribute :spelling, :string
      attribute :grammar, :string

      xml do
        element "proofState"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "spelling", to: :spelling
        map_attribute "grammar", to: :grammar
      end
    end
  end
end
