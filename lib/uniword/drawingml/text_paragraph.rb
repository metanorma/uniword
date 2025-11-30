# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Text paragraph
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:p>
    class TextParagraph < Lutaml::Model::Serializable
      attribute :runs, TextRun, collection: true, default: -> { [] }

      xml do
        element 'p'
        namespace Uniword::Ooxml::Namespaces::DrawingML
        mixed_content

        map_element 'r', to: :runs, render_nil: false
      end
    end
  end
end
