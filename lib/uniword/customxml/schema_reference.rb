# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Customxml
    # Schema reference entry (CT_DatastoreSchemaRef)
    #
    # Element: <ds:schemaRef>
    # Namespace: http://schemas.openxmlformats.org/officeDocument/2006/customXml
    class SchemaRef < Lutaml::Model::Serializable
      attribute :uri, :string

      xml do
        element 'schemaRef'
        namespace Uniword::Ooxml::Namespaces::CustomXml

        map_attribute 'uri', to: :uri
      end
    end

    # Schema references container (CT_DatastoreSchemaRefs)
    #
    # Element: <ds:schemaRefs>
    # Namespace: http://schemas.openxmlformats.org/officeDocument/2006/customXml
    class SchemaRefs < Lutaml::Model::Serializable
      attribute :refs, SchemaRef, collection: true, initialize_empty: true

      xml do
        element 'schemaRefs'
        namespace Uniword::Ooxml::Namespaces::CustomXml
        mixed_content

        map_element 'schemaRef', to: :refs, render_nil: false
      end
    end

    # Backward-compatible alias
    SchemaReference = SchemaRef
  end
end
