# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Customxml
      # Namespace URI for smart tag or custom XML
      #
      # Generated from OOXML schema: customxml.yml
      # Element: <cxml:uri>
      class NamespaceUri < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            element 'uri'
            namespace Uniword::Ooxml::Namespaces::CustomXml

            map_attribute 'val', to: :val
          end
      end
    end
end
