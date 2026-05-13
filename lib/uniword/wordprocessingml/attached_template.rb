# frozen_string_literal: true

require "lutaml/model"
require_relative "../properties/relationship_id"

module Uniword
  module Wordprocessingml
    class AttachedTemplate < Lutaml::Model::Serializable
      attribute :r_id, Properties::RelationshipIdValue

      xml do
        element "attachedTemplate"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "id", to: :r_id
      end
    end
  end
end
