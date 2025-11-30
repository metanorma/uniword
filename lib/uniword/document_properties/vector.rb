# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module DocumentProperties
    # Vector container for variant types
    #
    # Generated from OOXML schema: document_properties.yml
    # Element: <ep:vector>
    class Vector < Lutaml::Model::Serializable
      attribute :size, :string
      attribute :baseType, :string
      attribute :variant, :string, collection: true, default: -> { [] }

      xml do
        element 'vector'
        namespace Uniword::Ooxml::Namespaces::ExtendedProperties
        mixed_content

        map_attribute 'size', to: :size
        map_attribute 'baseType', to: :baseType
        map_element 'variant', to: :variant, render_nil: false
      end
    end
  end
end
