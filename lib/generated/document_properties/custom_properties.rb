# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module DocumentProperties
      # Root element for custom properties
      #
      # Generated from OOXML schema: document_properties.yml
      # Element: <ep:CustomProperties>
      class CustomProperties < Lutaml::Model::Serializable
          attribute :properties, CustomProperty, collection: true, default: -> { [] }

          xml do
            root 'CustomProperties'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/extended-properties', 'ep'
            mixed_content

            map_element 'property', to: :properties, render_nil: false
          end
      end
    end
  end
end
