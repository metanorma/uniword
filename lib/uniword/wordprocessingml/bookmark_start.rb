# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Wordprocessingml
      # Bookmark start marker
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:bookmarkStart>
      class BookmarkStart < Lutaml::Model::Serializable
          attribute :id, :string
          attribute :name, :string

          xml do
            element 'bookmarkStart'
            namespace Uniword::Ooxml::Namespaces::WordProcessingML

            map_attribute 'id', to: :id
            map_attribute 'name', to: :name
          end
      end
    end
end
