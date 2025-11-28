# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Customxml
      # Flag indicating whether placeholder is displayed
      #
      # Generated from OOXML schema: customxml.yml
      # Element: <cxml:showing_plc_hdr>
      class ShowingPlaceholder < Lutaml::Model::Serializable
          attribute :val, :boolean

          xml do
            root 'showing_plc_hdr'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/customXml', 'cxml'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
