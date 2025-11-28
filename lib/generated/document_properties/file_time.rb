# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module DocumentProperties
      # File time value type
      #
      # Generated from OOXML schema: document_properties.yml
      # Element: <ep:filetime>
      class FileTime < Lutaml::Model::Serializable
          attribute :content, String

          xml do
            root 'filetime'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/extended-properties', 'ep'

            map_element '', to: :content, render_nil: false
          end
      end
    end
  end
end
