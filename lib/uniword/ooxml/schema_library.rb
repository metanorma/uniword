# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Ooxml
    # Schema Library (shared-customXmlSchemaProperties.xsd)
    #
    # Defines a library of XML schemas used by custom XML markup.
    # Appears in word/settings.xml as <sl:schemaLibrary>.
    #
    # Namespace: http://schemas.openxmlformats.org/schemaLibrary/2006/main
    # Prefix: sl
    class SchemaLibEntry < Lutaml::Model::Serializable
      attribute :uri, :string, default: -> { "" }
      attribute :manifest_location, :string

      xml do
        element "schema"
        namespace Namespaces::SchemaLibrary

        map_attribute "uri", to: :uri
        map_attribute "manifestLocation", to: :manifest_location
      end
    end

    class SchemaLibrary < Lutaml::Model::Serializable
      attribute :schemas, SchemaLibEntry, collection: true,
                                          initialize_empty: true

      xml do
        element "schemaLibrary"
        namespace Namespaces::SchemaLibrary

        map_element "schema", to: :schemas, render_nil: false
      end
    end
  end
end
