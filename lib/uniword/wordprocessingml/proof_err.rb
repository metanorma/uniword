# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Proofing error marker
    #
    # Element: <w:proofErr>
    class ProofErr < Lutaml::Model::Serializable
      attribute :type, :string

      xml do
        element "proofErr"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "type", to: :type
      end
    end
  end
end
