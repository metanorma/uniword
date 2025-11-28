# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module DocumentProperties
      # Links up to date flag
      #
      # Generated from OOXML schema: document_properties.yml
      # Element: <ep:LinksUpToDate>
      class LinksUpToDate < Lutaml::Model::Serializable
          attribute :content, String

          xml do
            root 'LinksUpToDate'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/extended-properties', 'ep'

            map_element '', to: :content, render_nil: false
          end
      end
    end
  end
end
