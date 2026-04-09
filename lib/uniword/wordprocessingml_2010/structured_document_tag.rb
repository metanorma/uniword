# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml2010
    # Enhanced structured document tag for Word 2010+
    #
    # Generated from OOXML schema: wordprocessingml_2010.yml
    # Element: <w14:sdt>
    class StructuredDocumentTag < Lutaml::Model::Serializable
      attribute :properties, SdtProperties
      attribute :content, SdtContent

      xml do
        element 'sdt'
        namespace Uniword::Ooxml::Namespaces::Word2010
        mixed_content

        map_element 'sdtPr', to: :properties, render_nil: false
        map_element 'sdtContent', to: :content, render_nil: false
      end
    end
  end
end
