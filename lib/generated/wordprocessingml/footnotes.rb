# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Footnotes collection
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:footnotes>
      class Footnotes < Lutaml::Model::Serializable
          attribute :footnote_entries, Footnote, collection: true, default: -> { [] }

          xml do
            root 'footnotes'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'
            mixed_content

            map_element 'footnote', to: :footnote_entries, render_nil: false
          end
      end
    end
  end
end
