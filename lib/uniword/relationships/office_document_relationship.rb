# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Relationships
    # Office document relationship type
    #
    # Generated from OOXML schema: relationships.yml
    # Element: <r:OfficeDocumentRelationship>
    class OfficeDocumentRelationship < Lutaml::Model::Serializable
      attribute :constant_type, :string

      xml do
        element 'OfficeDocumentRelationship'
        namespace Uniword::Ooxml::Namespaces::Relationships

        map_attribute 'constant-type', to: :constant_type
      end
    end
  end
end
