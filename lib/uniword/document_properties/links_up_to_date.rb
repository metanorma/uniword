# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module DocumentProperties
    # Links up to date flag
    #
    # Generated from OOXML schema: document_properties.yml
    # Element: <ep:LinksUpToDate>
    class LinksUpToDate < Lutaml::Model::Serializable
      attribute :content, :string

      xml do
        element "LinksUpToDate"
        namespace Uniword::Ooxml::Namespaces::ExtendedProperties

        map_element "", to: :content, render_nil: false
      end
    end
  end
end
