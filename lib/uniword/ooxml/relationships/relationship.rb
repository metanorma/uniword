# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Ooxml
    module Relationships
      # Single relationship
      #
      # Generated from OOXML schema: relationships.yml
      # Element: <r:Relationship>
      class Relationship < Lutaml::Model::Serializable
        attribute :id, :string
        attribute :type, :string
        attribute :target, :string
        attribute :target_mode, :string

        xml do
          element 'Relationship'
          namespace Uniword::Ooxml::Namespaces::Relationships

          map_attribute 'id', to: :id
          map_attribute 'type', to: :type
          map_attribute 'target', to: :target
          map_attribute 'target-mode', to: :target_mode
        end
      end
    end
  end
end
