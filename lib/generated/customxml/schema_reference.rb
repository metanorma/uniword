# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Customxml
      # Reference to an XML schema for validation
      #
      # Generated from OOXML schema: customxml.yml
      # Element: <cxml:schema_reference>
      class SchemaReference < Lutaml::Model::Serializable
          attribute :uri, :string

          xml do
            root 'schema_reference'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/customXml', 'cxml'

            map_attribute 'uri', to: :uri
          end
      end
    end
  end
end
