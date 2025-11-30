# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Wordprocessingml2013
      # Person reference for collaborative editing
      #
      # Generated from OOXML schema: wordprocessingml_2013.yml
      # Element: <w15:person>
      class Person < Lutaml::Model::Serializable
          attribute :author, String
          attribute :provider_id, String
          attribute :user_id, String

          xml do
            element 'person'
            namespace Uniword::Ooxml::Namespaces::Word2012

            map_attribute 'author', to: :author
            map_attribute 'provider-id', to: :provider_id
            map_attribute 'user-id', to: :user_id
          end
      end
    end
end
