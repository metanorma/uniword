# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module DocumentProperties
    # Integer value type
    #
    # Generated from OOXML schema: document_properties.yml
    # Element: <ep:i4>
    class I4 < Lutaml::Model::Serializable
      attribute :content, :string

      xml do
        element "i4"
        namespace Uniword::Ooxml::Namespaces::ExtendedProperties

        map_element "", to: :content, render_nil: false
      end
    end
  end
end
