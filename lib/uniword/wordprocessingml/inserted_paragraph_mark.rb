# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Inserted paragraph mark
    #
    # Element: <w:ins> (CT_TrackChange) as it appears inside
    # <w:pPr>/<w:rPr>: the paragraph mark itself was inserted while
    # tracking changes, so the whole paragraph reads as a tracked
    # insertion and rejecting the revision removes the paragraph.
    # Carries only the revision identity.
    #
    # @example
    #   mark = InsertedParagraphMark.new(id: "10", author: "Alice")
    class InsertedParagraphMark < Lutaml::Model::Serializable
      attribute :id, Ooxml::Types::WmlVal
      attribute :author, Ooxml::Types::WmlVal
      attribute :date, Ooxml::Types::WmlVal

      xml do
        element "ins"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute "id", to: :id, render_nil: false
        map_attribute "author", to: :author, render_nil: false
        map_attribute "date", to: :date, render_nil: false
      end
    end
  end
end
