# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    class StructuredDocumentTag
      # Content container for Structured Document Tag
      # Contains the actual content (paragraphs, runs, tables, etc.)
      # Reference XML: <w:sdtContent><w:p>...</w:p></w:sdtContent>
      class Content < Lutaml::Model::Serializable
        attribute :paragraphs, Paragraph, collection: true, initialize_empty: true
        attribute :tables, Table, collection: true, initialize_empty: true
        attribute :sdts, StructuredDocumentTag, collection: true, initialize_empty: true

        xml do
          element 'sdtContent'
          namespace Ooxml::Namespaces::WordProcessingML
          mixed_content

          map_element 'p', to: :paragraphs, render_nil: false
          map_element 'tbl', to: :tables, render_nil: false
          map_element 'sdt', to: :sdts, render_nil: false
        end
      end
    end
  end
end
