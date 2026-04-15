# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Ooxml
    module Types
      # Dublin Core Terms created element type
      class DctermsCreatedType < Lutaml::Model::Serializable
        attribute :value, :string
        attribute :type, :string

        xml do
          element "created"
          namespace Ooxml::Namespaces::DublinCoreTerms

          map_content to: :value
          # xsi:type attribute - handled without explicit namespace in new lutaml-model
          map_attribute "type", to: :type
        end
      end
    end
  end
end
