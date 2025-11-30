# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module DocumentProperties
      # Application name that created the document
      #
      # Generated from OOXML schema: document_properties.yml
      # Element: <ep:Application>
      class Application < Lutaml::Model::Serializable
          attribute :content, String

          xml do
            element 'Application'
            namespace Uniword::Ooxml::Namespaces::ExtendedProperties

            map_element '', to: :content, render_nil: false
          end
      end
    end
end
