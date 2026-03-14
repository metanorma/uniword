# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    class StructuredDocumentTag
      # Temporary flag for Structured Document Tag (empty element)
      # Indicates the SDT should be removed when content is first edited
      # Reference XML: <w:temporary/>
      class Temporary < Lutaml::Model::Serializable
        xml do
          element 'temporary'
          namespace Ooxml::Namespaces::WordProcessingML
        end
      end
    end
  end
end
