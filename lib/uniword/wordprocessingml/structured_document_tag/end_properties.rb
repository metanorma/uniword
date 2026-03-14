# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    class StructuredDocumentTag
      # End properties for Structured Document Tag
      # Contains run-level formatting for the SDT end marker
      # Reference XML: <w:sdtEndPr>...</w:sdtEndPr>
      class EndProperties < Lutaml::Model::Serializable
        # End properties typically contains run properties (rPr)
        # Uses mixed_content to preserve whatever formatting is inside
        xml do
          element 'sdtEndPr'
          namespace Ooxml::Namespaces::WordProcessingML
          mixed_content
        end
      end
    end
  end
end
