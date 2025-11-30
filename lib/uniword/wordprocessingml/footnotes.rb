# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Wordprocessingml
      # Footnotes collection
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:footnotes>
      class Footnotes < Lutaml::Model::Serializable
          attribute :footnote_entries, Footnote, collection: true, default: -> { [] }

          xml do
            element 'footnotes'
            namespace Uniword::Ooxml::Namespaces::WordProcessingML
            mixed_content

            map_element 'footnote', to: :footnote_entries, render_nil: false
          end
      end
    end
end
