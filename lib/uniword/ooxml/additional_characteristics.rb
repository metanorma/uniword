# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Ooxml
    # Additional Characteristics (shared-additionalCharacteristics.xsd)
    #
    # Stores additional document characteristics like format capabilities.
    # Rarely used in standard Word documents.
    #
    # Namespace: http://schemas.openxmlformats.org/officeDocument/2006/characteristics
    class Characteristic < Lutaml::Model::Serializable
      attribute :name, :string
      attribute :relation, :string
      attribute :val, :string
      attribute :vocabulary, :string

      xml do
        element "characteristic"
        namespace Namespaces::Characteristics

        map_attribute "name", to: :name
        map_attribute "relation", to: :relation
        map_attribute "val", to: :val
        map_attribute "vocabulary", to: :vocabulary
      end
    end

    # Root element for additional characteristics
    class AdditionalCharacteristics < Lutaml::Model::Serializable
      attribute :characteristics, Characteristic, collection: true,
                                                  initialize_empty: true

      xml do
        element "additionalCharacteristics"
        namespace Namespaces::Characteristics

        map_element "characteristic", to: :characteristics, render_nil: false
      end
    end
  end
end
