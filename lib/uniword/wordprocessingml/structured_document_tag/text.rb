# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    class StructuredDocumentTag
      # Text control flag for Structured Document Tag (empty element)
      # Reference XML: <w:text/>
      class Text < Lutaml::Model::Serializable
        xml do
          element 'text'
          namespace Ooxml::Namespaces::WordProcessingML
        end
      end
    end
  end
end
