# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Relationships
    # Hyperlink relationship type
    #
    # Generated from OOXML schema: relationships.yml
    # Element: <r:HyperlinkRelationship>
    class HyperlinkRelationship < Lutaml::Model::Serializable
      attribute :constant_type, :string

      xml do
        element 'HyperlinkRelationship'
        namespace Uniword::Ooxml::Namespaces::Relationships

        map_attribute 'constant-type', to: :constant_type
      end
    end
  end
end
