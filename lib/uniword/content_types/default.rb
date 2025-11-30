# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module ContentTypes
      # Default content type for file extension
      #
      # Generated from OOXML schema: content_types.yml
      # Element: <ct:Default>
      class Default < Lutaml::Model::Serializable
          attribute :extension, String
          attribute :content_type, String

          xml do
            element 'Default'
            namespace Uniword::Ooxml::Namespaces::ContentTypes

            map_attribute 'extension', to: :extension
            map_attribute 'content_type', to: :content_type
          end
      end
    end
end
