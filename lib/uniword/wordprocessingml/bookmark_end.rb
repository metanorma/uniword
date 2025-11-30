# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Bookmark end marker
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:bookmarkEnd>
    class BookmarkEnd < Lutaml::Model::Serializable
      attribute :id, :string

      xml do
        element 'bookmarkEnd'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute 'id', to: :id
      end
    end
  end
end
