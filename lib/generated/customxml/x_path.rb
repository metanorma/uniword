# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Customxml
      # XPath expression for data selection
      #
      # Generated from OOXML schema: customxml.yml
      # Element: <cxml:xpath>
      class XPath < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            root 'xpath'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/customXml', 'cxml'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
