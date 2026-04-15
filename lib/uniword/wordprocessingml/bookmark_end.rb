# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Bookmark end marker
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:bookmarkEnd>
    class BookmarkEnd < Lutaml::Model::Serializable
      attribute :id, :string
      attribute :displaced_by_custom_xml, Uniword::Properties::DisplacedByCustomXmlValue

      xml do
        element "bookmarkEnd"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute "id", to: :id
        map_attribute "displacedByCustomXml", to: :displaced_by_custom_xml
      end
    end
  end
end
