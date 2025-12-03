# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Text box content container
    # Shared by VML and DrawingML text boxes
    # Contains paragraphs, tables, and structured document tags
    class TextBoxContent < Lutaml::Model::Serializable
      # PATTERN 0: Attributes FIRST
      attribute :paragraphs, Paragraph, collection: true, default: -> { [] }
      attribute :tables, Table, collection: true, default: -> { [] }
      attribute :sdts, StructuredDocumentTag, collection: true, default: -> { [] }

      xml do
        root 'txbxContent'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_element 'p', to: :paragraphs, render_nil: false
        map_element 'tbl', to: :tables, render_nil: false
        map_element 'sdt', to: :sdts, render_nil: false
      end
    end
  end
end