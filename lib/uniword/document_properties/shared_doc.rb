# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module DocumentProperties
      # Shared document flag
      #
      # Generated from OOXML schema: document_properties.yml
      # Element: <ep:SharedDoc>
      class SharedDoc < Lutaml::Model::Serializable
          attribute :content, String

          xml do
            element 'SharedDoc'
            namespace Uniword::Ooxml::Namespaces::ExtendedProperties

            map_element '', to: :content, render_nil: false
          end
      end
    end
end
