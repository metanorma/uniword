# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Customxml
      # Smart tag type definition with namespace and element information
      #
      # Generated from OOXML schema: customxml.yml
      # Element: <cxml:smart_tag_type>
      class SmartTagType < Lutaml::Model::Serializable
          attribute :namespace_uri, :string
          attribute :name, :string
          attribute :url, :string

          xml do
            root 'smart_tag_type'
            namespace 'http://schemas.openxmlformats.org/officeDocument/2006/customXml', 'cxml'

            map_attribute 'namespaceuri', to: :namespace_uri
            map_attribute 'name', to: :name
            map_attribute 'url', to: :url
          end
      end
    end
  end
end
