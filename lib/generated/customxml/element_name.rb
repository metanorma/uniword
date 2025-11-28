# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Customxml
      # Smart tag element name specification
      #
      # Generated from OOXML schema: customxml.yml
      # Element: <cxml:element>
      class ElementName < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            root 'element'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/customXml', 'cxml'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
