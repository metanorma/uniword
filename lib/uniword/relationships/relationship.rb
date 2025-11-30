# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Relationships
    # Single relationship
    #
    # Generated from OOXML schema: relationships.yml
    # Element: <r:Relationship>
    class Relationship < Lutaml::Model::Serializable
      attribute :id, String
      attribute :type, String
      attribute :target, String
      attribute :target_mode, String

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
