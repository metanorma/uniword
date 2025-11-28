# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Text paragraph
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:p>
      class TextParagraph < Lutaml::Model::Serializable
          attribute :runs, TextRun, collection: true, default: -> { [] }

          xml do
            root 'p'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'
            mixed_content

            map_element 'r', to: :runs, render_nil: false
          end
      end
    end
  end
end
