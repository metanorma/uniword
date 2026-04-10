# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Reference to header part
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:headerReference>
    class HeaderReference < Lutaml::Model::Serializable
      attribute :type, :string
      attribute :r_id, :string

      xml do
        element 'headerReference'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        namespace_scope [
          { namespace: Uniword::Ooxml::Namespaces::Relationships, declare: :auto }
        ]

        map_attribute 'type', to: :type
        map_attribute 'r:id', to: :r_id
      end
    end
  end
end
