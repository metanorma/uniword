# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module DocumentProperties
      # Vector of heading pairs
      #
      # Generated from OOXML schema: document_properties.yml
      # Element: <ep:HeadingPairs>
      class HeadingPairs < Lutaml::Model::Serializable
          attribute :vector, Vector

          xml do
            element 'HeadingPairs'
            namespace Uniword::Ooxml::Namespaces::ExtendedProperties
            mixed_content

            map_element 'vector', to: :vector, render_nil: false
          end
      end
    end
end
