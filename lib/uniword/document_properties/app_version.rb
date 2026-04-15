# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module DocumentProperties
    # Application version
    #
    # Generated from OOXML schema: document_properties.yml
    # Element: <ep:AppVersion>
    class AppVersion < Lutaml::Model::Serializable
      attribute :content, :string

      xml do
        element "AppVersion"
        namespace Uniword::Ooxml::Namespaces::ExtendedProperties

        map_element "", to: :content, render_nil: false
      end
    end
  end
end
