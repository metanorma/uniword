# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Reference to footer part
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:footerReference>
    class FooterReference < Lutaml::Model::Serializable
      attribute :type, :string
      attribute :r_id, :string

      xml do
        element 'footerReference'
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
