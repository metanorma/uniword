# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module ContentTypes
    # Override content type for specific part
    #
    # Generated from OOXML schema: content_types.yml
    # Element: <ct:Override>
    class Override < Lutaml::Model::Serializable
      attribute :part_name, :string
      attribute :content_type, :string

      xml do
        element 'Override'
        namespace Uniword::Ooxml::Namespaces::ContentTypes

        map_attribute 'PartName', to: :part_name
        map_attribute 'ContentType', to: :content_type
      end
    end
  end
end
