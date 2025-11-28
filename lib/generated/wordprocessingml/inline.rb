# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Inline drawing object
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:inline>
      class Inline < Lutaml::Model::Serializable
          attribute :extent, Extent
          attribute :docPr, DocPr
          attribute :graphic, Graphic

          xml do
            root 'inline'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'
            mixed_content

            map_element 'extent', to: :extent, render_nil: false
            map_element 'docPr', to: :docPr, render_nil: false
            map_element 'graphic', to: :graphic, render_nil: false
          end
      end
    end
  end
end
