# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Office
    # Proof state
    #
    # Generated from OOXML schema: office.yml
    # Element: <o:proofstate>
    class ProofState < Lutaml::Model::Serializable
      attribute :spelling, :string
      attribute :grammar, :string

      xml do
        element "proofstate"
        namespace Uniword::Ooxml::Namespaces::Office

        map_attribute "spelling", to: :spelling
        map_attribute "grammar", to: :grammar
      end
    end
  end
end
