# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Customxml
      # Flag indicating whether placeholder header is shown
      #
      # Generated from OOXML schema: customxml.yml
      # Element: <cxml:showing_placeholder_header>
      class ShowingPlaceholderHeader < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            root 'showing_placeholder_header'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/customXml', 'cxml'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
