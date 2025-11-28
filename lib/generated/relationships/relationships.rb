# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Relationships
      # Relationships root element
      #
      # Generated from OOXML schema: relationships.yml
      # Element: <r:Relationships>
      class Relationships < Lutaml::Model::Serializable
          attribute :relationships, Relationship, collection: true, default: -> { [] }

          xml do
            root 'Relationships'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/relationships', 'r'
            mixed_content

            map_element 'Relationship', to: :relationships, render_nil: false
          end
      end
    end
  end
end
