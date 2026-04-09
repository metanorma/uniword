# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    class StructuredDocumentTag
      # Bibliography flag for Structured Document Tag (empty element)
      # Reference XML: <w:bibliography/>
      class Bibliography < Lutaml::Model::Serializable
        xml do
          element 'bibliography'
          namespace Ooxml::Namespaces::WordProcessingML
        end
      end
    end
  end
end
