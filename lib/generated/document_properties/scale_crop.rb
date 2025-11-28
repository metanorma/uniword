# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module DocumentProperties
      # Scale crop setting for thumbnails
      #
      # Generated from OOXML schema: document_properties.yml
      # Element: <ep:ScaleCrop>
      class ScaleCrop < Lutaml::Model::Serializable
          attribute :content, String

          xml do
            root 'ScaleCrop'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/extended-properties', 'ep'

            map_element '', to: :content, render_nil: false
          end
      end
    end
  end
end
