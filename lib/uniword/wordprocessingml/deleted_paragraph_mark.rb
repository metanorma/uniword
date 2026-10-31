# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Deleted paragraph mark
    #
    # Element: <w:del> (CT_TrackChange) as it appears inside
    # <w:pPr>/<w:rPr>: the paragraph mark itself was deleted while
    # tracking changes, so accepting the revision merges the paragraph
    # with the following one. Carries only the revision identity; the
    # deleted text lives in sibling <w:del> run wrappers.
    #
    # @example
    #   mark = DeletedParagraphMark.new(id: "9", author: "Alice")
    class DeletedParagraphMark < Lutaml::Model::Serializable
      attribute :id, Ooxml::Types::WmlVal
      attribute :author, Ooxml::Types::WmlVal
      attribute :date, Ooxml::Types::WmlVal

      xml do
        element "del"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute "id", to: :id, render_nil: false
        map_attribute "author", to: :author, render_nil: false
        map_attribute "date", to: :date, render_nil: false
      end
    end
  end
end
