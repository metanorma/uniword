# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Customxml
    # Smart tag element for context-aware metadata
    #
    # Generated from OOXML schema: customxml.yml
    # Element: <cxml:smart_tag>
    class SmartTag < Lutaml::Model::Serializable
      attribute :uri, :string
      attribute :element, :string
      attribute :smart_tag_pr, SmartTagProperties
      attribute :content, :string, collection: true, initialize_empty: true

      xml do
        element 'smart_tag'
        namespace Uniword::Ooxml::Namespaces::CustomXml
        mixed_content

        map_attribute 'uri', to: :uri
        map_attribute 'element', to: :element
        map_element 'smartTagPr', to: :smart_tag_pr, render_nil: false
        map_element '', to: :content, render_nil: false
      end
    end
  end
end
