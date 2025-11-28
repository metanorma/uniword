# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module DocumentProperties
      # Vector of heading pairs
      #
      # Generated from OOXML schema: document_properties.yml
      # Element: <ep:HeadingPairs>
      class HeadingPairs < Lutaml::Model::Serializable
          attribute :vector, Vector

          xml do
            root 'HeadingPairs'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/extended-properties', 'ep'
            mixed_content

            map_element 'vector', to: :vector, render_nil: false
          end
      end
    end
  end
end
