# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
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
            root 'author'
            namespace 'http://schemas.microsoft.com/office/word/2012/wordml', 'w15'

            map_attribute 'true', to: :name
            map_attribute 'true', to: :initials
            map_attribute 'true', to: :provider_id
          end
      end
    end
  end
end
