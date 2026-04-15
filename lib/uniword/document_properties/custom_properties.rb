# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module DocumentProperties
    # Root element for custom properties
    #
    # Generated from OOXML schema: document_properties.yml
    # Element: <ep:CustomProperties>
    class CustomProperties < Lutaml::Model::Serializable
      attribute :properties, CustomProperty, collection: true, initialize_empty: true

      xml do
        element "CustomProperties"
        namespace Uniword::Ooxml::Namespaces::ExtendedProperties
        mixed_content

        map_element "property", to: :properties, render_nil: false
      end
    end
  end
end
