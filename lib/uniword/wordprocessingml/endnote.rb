# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Endnote definition
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:endnote>
    class Endnote < Lutaml::Model::Serializable
      attribute :id, :string
      attribute :type, :string
      attribute :paragraphs, Paragraph, collection: true, initialize_empty: true

      xml do
        element "endnote"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_attribute "id", to: :id
        map_attribute "type", to: :type
        map_element "p", to: :paragraphs, render_nil: false
      end
    end
  end
end
