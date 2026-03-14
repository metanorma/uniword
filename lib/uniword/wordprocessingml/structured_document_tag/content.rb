# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    class StructuredDocumentTag
      # Content container for Structured Document Tag
      # Contains the actual content (paragraphs, runs, tables, etc.)
      # Reference XML: <w:sdtContent><w:p>...</w:p></w:sdtContent>
      class Content < Lutaml::Model::Serializable
        # Content uses mixed_content to preserve whatever is inside
        # (paragraphs, runs, tables, etc.)
        xml do
          element 'sdtContent'
          namespace Ooxml::Namespaces::WordProcessingML
          mixed_content
        end
      end
    end
  end
end
