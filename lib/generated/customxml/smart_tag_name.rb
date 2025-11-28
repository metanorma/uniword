# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Customxml
      # Name for smart tag type
      #
      # Generated from OOXML schema: customxml.yml
      # Element: <cxml:smart_tag_name>
      class SmartTagName < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            root 'smart_tag_name'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/customXml', 'cxml'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
