# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Wordprocessingml2013
      # Enhanced comment author information
      #
      # Generated from OOXML schema: wordprocessingml_2013.yml
      # Element: <w15:author>
      class CommentAuthor < Lutaml::Model::Serializable
          attribute :name, String
          attribute :initials, String
          attribute :provider_id, String

          xml do
            element 'author'
            namespace Uniword::Ooxml::Namespaces::Word2012

            map_attribute 'name', to: :name
            map_attribute 'initials', to: :initials
            map_attribute 'provider-id', to: :provider_id
          end
      end
    end
end
