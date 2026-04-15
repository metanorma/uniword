# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    class StructuredDocumentTag
      # Showing placeholder header flag for Structured Document Tag (empty element)
      # Reference XML: <w:showingPlcHdr/>
      class ShowingPlaceholderHeader < Lutaml::Model::Serializable
        xml do
          element "showingPlcHdr"
          namespace Ooxml::Namespaces::WordProcessingML
        end
      end
    end
  end
end
