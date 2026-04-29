# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Ooxml
    module Types
      # String type in the Relationships namespace.
      # Used for cross-namespace attributes like r:embed and r:link on
      # elements from other namespaces (e.g., <a:blip r:embed="rIdImg1"/>).
      class RelationshipId < Lutaml::Model::Type::String
        xml do
          namespace Uniword::Ooxml::Namespaces::Relationships
        end
      end
    end
  end
end
