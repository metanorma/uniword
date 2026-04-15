# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module ContentTypes
    # Content types root element for [Content_Types].xml
    #
    # Generated from OOXML schema: content_types.yml
    # Element: <ct:Types>
    class Types < Lutaml::Model::Serializable
      attribute :defaults, Default, collection: true, initialize_empty: true
      attribute :overrides, Override, collection: true, initialize_empty: true

      xml do
        element "Types"
        namespace Uniword::Ooxml::Namespaces::ContentTypes
        mixed_content
        ordered

        map_element "Default", to: :defaults, render_nil: false
        map_element "Override", to: :overrides, render_nil: false
      end
    end
  end
end
