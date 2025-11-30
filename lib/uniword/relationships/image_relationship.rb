# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Relationships
    # Image relationship type
    #
    # Generated from OOXML schema: relationships.yml
    # Element: <r:ImageRelationship>
    class ImageRelationship < Lutaml::Model::Serializable
      attribute :constant_type, String

      xml do
        element 'ImageRelationship'
        namespace Uniword::Ooxml::Namespaces::Relationships

        map_attribute 'constant-type', to: :constant_type
      end
    end
  end
end
