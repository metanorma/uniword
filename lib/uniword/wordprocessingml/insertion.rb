# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Tracked insertion
    #
    # Element: <w:ins> (CT_RunTrackChange) — wraps the runs Word
    # inserted while tracking changes. Attributes identify the
    # revision; the wrapped runs are live content.
    #
    # @example
    #   ins = Insertion.new(id: "7", author: "Alice",
    #                        runs: [Run.new(text: "inserted")])
    class Insertion < Lutaml::Model::Serializable
      attribute :id, :string
      attribute :author, :string
      attribute :date, :string
      attribute :runs, Run, collection: true, initialize_empty: true

      xml do
        element "ins"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_attribute "id", to: :id, render_nil: false
        map_attribute "author", to: :author, render_nil: false
        map_attribute "date", to: :date, render_nil: false
        map_element "r", to: :runs, render_nil: false
      end

      # Text of the wrapped runs (live content).
      #
      # @return [String]
      def text
        runs.map(&:text_string).join
      end
    end
  end
end
