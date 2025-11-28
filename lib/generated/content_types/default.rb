# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module ContentTypes
      # Default content type for file extension
      #
      # Generated from OOXML schema: content_types.yml
      # Element: <ct:Default>
      class Default < Lutaml::Model::Serializable
          attribute :extension, String
          attribute :content_type, String

          xml do
            root 'Default'
            namespace 'http://schemas.openxmlformats.org/package/2006/content-types', 'ct'

            map_attribute 'true', to: :extension
            map_attribute 'true', to: :content_type
          end
      end
    end
  end
end
