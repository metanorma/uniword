# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Customxml
      # Namespace prefix mappings for XPath expressions
      #
      # Generated from OOXML schema: customxml.yml
      # Element: <cxml:prefix_mappings>
      class PrefixMappings < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            root 'prefix_mappings'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/customXml', 'cxml'

            map_attribute 'val', to: :val
          end
      end
    end
  end
end
