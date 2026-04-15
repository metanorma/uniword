# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    class StructuredDocumentTag
      # End properties for Structured Document Tag
      # Contains run-level formatting for the SDT end marker
      # Reference XML: <w:sdtEndPr>...</w:sdtEndPr>
      class EndProperties < Lutaml::Model::Serializable
        attribute :run_properties, Uniword::Wordprocessingml::RunProperties

        xml do
          element "sdtEndPr"
          namespace Ooxml::Namespaces::WordProcessingML
          mixed_content

          map_element "rPr", to: :run_properties, render_nil: false
        end
      end
    end
  end
end
