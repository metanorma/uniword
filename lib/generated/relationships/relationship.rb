# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
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
            root 'Relationship'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/relationships', 'r'

            map_attribute 'true', to: :id
            map_attribute 'true', to: :type
            map_attribute 'true', to: :target
            map_attribute 'true', to: :target_mode
          end
      end
    end
  end
end
