# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Ooxml
    module Types
      # Dublin Core Terms modified element type
      class DctermsModifiedType < Lutaml::Model::Serializable
        attribute :value, :string
        attribute :type, :string

        xml do
          element "modified"
          namespace Ooxml::Namespaces::DublinCoreTerms

          map_content to: :value
          # xsi:type attribute - handled without explicit namespace in new lutaml-model
          map_attribute "type", to: :type
        end
      end
    end
  end
end
