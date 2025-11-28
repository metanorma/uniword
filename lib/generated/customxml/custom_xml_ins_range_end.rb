# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Customxml
      # End marker for custom XML insertion range in track changes
      #
      # Generated from OOXML schema: customxml.yml
      # Element: <cxml:custom_xml_ins_range_end>
      class CustomXmlInsRangeEnd < Lutaml::Model::Serializable
          attribute :id, :string

          xml do
            root 'custom_xml_ins_range_end'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/customXml', 'cxml'

            map_attribute 'id', to: :id
          end
      end
    end
  end
end
