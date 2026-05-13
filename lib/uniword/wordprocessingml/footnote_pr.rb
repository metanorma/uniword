# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    class FootnotePr < Lutaml::Model::Serializable
      attribute :pos, FootnotePos
      attribute :footnotes, Footnote, collection: true

      xml do
        element "footnotePr"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content
        map_element "pos", to: :pos, render_nil: false
        map_element "footnote", to: :footnotes, render_nil: false
      end
    end
  end
end
