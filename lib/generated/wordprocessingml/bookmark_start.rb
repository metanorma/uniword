# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Bookmark start marker
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:bookmarkStart>
      class BookmarkStart < Lutaml::Model::Serializable
          attribute :id, :string
          attribute :name, :string

          xml do
            root 'bookmarkStart'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

            map_attribute 'true', to: :id
            map_attribute 'true', to: :name
          end
      end
    end
  end
end
