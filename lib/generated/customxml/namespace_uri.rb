# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Customxml
      # Namespace URI for smart tag or custom XML
      #
      # Generated from OOXML schema: customxml.yml
      # Element: <cxml:uri>
      class NamespaceUri < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            root 'uri'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/customXml', 'cxml'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
