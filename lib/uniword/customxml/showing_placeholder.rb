# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Customxml
      # Flag indicating whether placeholder is displayed
      #
      # Generated from OOXML schema: customxml.yml
      # Element: <cxml:showing_plc_hdr>
      class ShowingPlaceholder < Lutaml::Model::Serializable
          attribute :val, :boolean

          xml do
            element 'showing_plc_hdr'
            namespace Uniword::Ooxml::Namespaces::CustomXml

            map_attribute 'val', to: :val
          end
      end
    end
end
