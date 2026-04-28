# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Drawingml
    # Text body container
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:txBody>
    class TextBody < Lutaml::Model::Serializable
      attribute :body_pr, BodyProperties
      attribute :paragraphs, TextParagraph, collection: true,
                                            initialize_empty: true

      xml do
        element "txBody"
        namespace Uniword::Ooxml::Namespaces::DrawingML
        mixed_content

        map_element "bodyPr", to: :body_pr
        map_element "p", to: :paragraphs, render_nil: false
      end
    end
  end
end
