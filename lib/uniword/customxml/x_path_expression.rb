# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Customxml
    # XPath expression for data selection
    #
    # Generated from OOXML schema: customxml.yml
    # Element: <cxml:xpath>
    class XPathExpression < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "xpath"
        namespace Uniword::Ooxml::Namespaces::CustomXml

        map_attribute "val", to: :val
      end
    end
  end
end
