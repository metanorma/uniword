# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Wordprocessingml
      # DrawingML object
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:drawing>
      class Drawing < Lutaml::Model::Serializable
          attribute :inline, Inline
          attribute :anchor, Anchor

          xml do
            element 'drawing'
            namespace Uniword::Ooxml::Namespaces::WordProcessingML
            mixed_content

            map_element 'inline', to: :inline, render_nil: false
            map_element 'anchor', to: :anchor, render_nil: false
          end
      end
    end
end
