# frozen_string_literal: true

require "lutaml/model"
require_relative "../properties/relationship_id"

module Uniword
  module Wordprocessingml
    # Reference to footer part
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:footerReference>
    class FooterReference < Lutaml::Model::Serializable
      attribute :type, :string
      attribute :r_id, Properties::RelationshipIdValue

      xml do
        element "footerReference"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute "type", to: :type
        map_attribute "id", to: :r_id
      end
    end
  end
end
