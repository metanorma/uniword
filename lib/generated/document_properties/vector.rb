# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module DocumentProperties
      # Vector container for variant types
      #
      # Generated from OOXML schema: document_properties.yml
      # Element: <ep:vector>
      class Vector < Lutaml::Model::Serializable
          attribute :size, String
          attribute :baseType, String
          attribute :variant, String, collection: true, default: -> { [] }

          xml do
            root 'vector'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/extended-properties', 'ep'
            mixed_content

            map_attribute 'true', to: :size
            map_attribute 'true', to: :baseType
            map_element 'variant', to: :variant, render_nil: false
          end
      end
    end
  end
end
