# frozen_string_literal: true

require 'lutaml/model'
# NOTE: StructuredDocumentTagProperties is autoloaded via wordprocessingml.rb (same namespace)

module Uniword
  module Wordprocessingml
    # Structured document tag (main WordProcessingML namespace)
    # Reference XML: <w:sdt>
    class StructuredDocumentTag < Lutaml::Model::Serializable
      attribute :properties, StructuredDocumentTagProperties
      attribute :end_properties, SdtEndProperties
      attribute :content, SdtContent

      xml do
        element 'sdt'
        namespace Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_element 'sdtPr', to: :properties, render_nil: false
        map_element 'sdtEndPr', to: :end_properties, render_nil: false
        map_element 'sdtContent', to: :content, render_nil: false
      end
    end
  end
end
