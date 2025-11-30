# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Relationships
      # Relationships root element
      #
      # Generated from OOXML schema: relationships.yml
      # Element: <r:Relationships>
      class Relationships < Lutaml::Model::Serializable
          attribute :relationships, Relationship, collection: true, default: -> { [] }

          xml do
            element 'Relationships'
            namespace Uniword::Ooxml::Namespaces::Relationships
            mixed_content

            map_element 'Relationship', to: :relationships, render_nil: false
          end
      end
    end
end
