# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Ooxml
    module Relationships
      # Package-level Relationship (for _rels/.rels files)
      #
      # Uses package namespace with unqualified attributes (Id, Type, Target)
      class PackageRelationship < Lutaml::Model::Serializable
        attribute :id, :string
        attribute :type, :string
        attribute :target, :string
        attribute :target_mode, :string

        xml do
          element "Relationship"
          namespace Uniword::Ooxml::Namespaces::PackageRelationships

          map_attribute "Id", to: :id
          map_attribute "Type", to: :type
          map_attribute "Target", to: :target
          map_attribute "TargetMode", to: :target_mode
        end
      end
    end
  end
end
