# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Presentationml
      # Text content and formatting within a shape
      #
      # Generated from OOXML schema: presentationml.yml
      # Element: <p:tx_body>
      class TextBody < Lutaml::Model::Serializable
          attribute :body_pr, BodyProperties
          attribute :lst_style, ListStyle
          attribute :p, Paragraph, collection: true, default: -> { [] }

          xml do
            root 'tx_body'
            namespace 'http://schemas.openxmlformats.org/presentationml/2006/main', 'p'
            mixed_content

            map_element 'bodyPr', to: :body_pr
            map_element 'lstStyle', to: :lst_style, render_nil: false
            map_element 'p', to: :p
          end
      end
    end
  end
end
