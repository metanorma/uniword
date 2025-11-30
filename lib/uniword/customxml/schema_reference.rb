# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Customxml
      # Reference to an XML schema for validation
      #
      # Generated from OOXML schema: customxml.yml
      # Element: <cxml:schema_reference>
      class SchemaReference < Lutaml::Model::Serializable
          attribute :uri, :string

          xml do
            element 'schema_reference'
            namespace Uniword::Ooxml::Namespaces::CustomXml

            map_attribute 'uri', to: :uri
          end
      end
    end
end
