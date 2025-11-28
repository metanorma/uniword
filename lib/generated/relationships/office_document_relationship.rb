# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Relationships
      # Office document relationship type
      #
      # Generated from OOXML schema: relationships.yml
      # Element: <r:OfficeDocumentRelationship>
      class OfficeDocumentRelationship < Lutaml::Model::Serializable
          attribute :constant_type, String

          xml do
            root 'OfficeDocumentRelationship'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/relationships', 'r'

            map_attribute 'true', to: :constant_type
          end
      end
    end
  end
end
