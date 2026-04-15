# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Customxml
    # Namespace prefix mappings for XPath expressions
    #
    # Generated from OOXML schema: customxml.yml
    # Element: <cxml:prefix_mappings>
    class PrefixMappings < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "prefix_mappings"
        namespace Uniword::Ooxml::Namespaces::CustomXml

        map_attribute "val", to: :val
      end
    end
  end
end
