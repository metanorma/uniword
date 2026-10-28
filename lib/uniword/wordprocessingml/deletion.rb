# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Tracked deletion
    #
    # Element: <w:del> (CT_RunTrackChange) — wraps the runs Word
    # deleted while tracking changes. The wrapped runs carry their
    # text in <w:delText> elements (deleted content, excluded from
    # paragraph text until the deletion is rejected).
    #
    # @example
    #   del = Deletion.new(id: "8", author: "Alice")
    class Deletion < Lutaml::Model::Serializable
      attribute :id, Ooxml::Types::WmlVal
      attribute :author, Ooxml::Types::WmlVal
      attribute :date, Ooxml::Types::WmlVal
      attribute :runs, Run, collection: true, initialize_empty: true

      xml do
        element "del"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_attribute "id", to: :id, render_nil: false
        map_attribute "author", to: :author, render_nil: false
        map_attribute "date", to: :date, render_nil: false
        map_element "r", to: :runs, render_nil: false
      end

      # Text of the deleted content (from <w:delText> elements).
      #
      # @return [String]
      def text
        runs.map { |run| run.del_text&.content.to_s }.join
      end
    end
  end
end
