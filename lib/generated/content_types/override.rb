# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module ContentTypes
      # Override content type for specific part
      #
      # Generated from OOXML schema: content_types.yml
      # Element: <ct:Override>
      class Override < Lutaml::Model::Serializable
          attribute :part_name, String
          attribute :content_type, String

          xml do
            root 'Override'
            namespace 'http://schemas.openxmlformats.org/package/2006/content-types', 'ct'

            map_attribute 'true', to: :part_name
            map_attribute 'true', to: :content_type
          end
      end
    end
  end
end
