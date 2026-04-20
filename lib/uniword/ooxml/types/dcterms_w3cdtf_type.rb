# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Ooxml
    module Types
      # Dublin Core Terms W3CDTF type indicator
      # This is the type value used in xsi:type="dcterms:W3CDTF"
      class DctermsW3cdtfType < Lutaml::Model::Serializable
        attribute :value, :string

        xml do
          root "W3CDTF"
          namespace Namespaces::DublinCoreTerms
        end
      end
    end
  end
end
