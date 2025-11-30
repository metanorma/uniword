# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module DocumentProperties
      # Variant type element
      #
      # Generated from OOXML schema: document_properties.yml
      # Element: <ep:variant>
      class Variant < Lutaml::Model::Serializable
          attribute :lpstr, String
          attribute :i4, String

          xml do
            element 'variant'
            namespace Uniword::Ooxml::Namespaces::ExtendedProperties
            mixed_content

            map_element 'lpstr', to: :lpstr, render_nil: false
            map_element 'i4', to: :i4, render_nil: false
          end
      end
    end
end
