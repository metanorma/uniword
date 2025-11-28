# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Customxml
      # Name value for smart tag or custom XML
      #
      # Generated from OOXML schema: customxml.yml
      # Element: <cxml:name>
      class Name < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            root 'name'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/customXml', 'cxml'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
