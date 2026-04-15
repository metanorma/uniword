# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module DocumentProperties
    # Company name
    #
    # Generated from OOXML schema: document_properties.yml
    # Element: <ep:Company>
    class Company < Lutaml::Model::Serializable
      attribute :content, :string

      xml do
        element "Company"
        namespace Uniword::Ooxml::Namespaces::ExtendedProperties

        map_element "", to: :content, render_nil: false
      end
    end
  end
end
