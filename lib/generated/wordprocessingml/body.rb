# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Document body - main content container
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:body>
      class Body < Lutaml::Model::Serializable
          attribute :paragraphs, Paragraph, collection: true, default: -> { [] }
          attribute :tables, Table, collection: true, default: -> { [] }
          attribute :section_properties, SectionProperties

          xml do
            root 'body'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'
            mixed_content

            map_element 'p', to: :paragraphs, render_nil: false
            map_element 'tbl', to: :tables, render_nil: false
            map_element 'sectPr', to: :section_properties, render_nil: false
          end
      end
    end
  end
end
