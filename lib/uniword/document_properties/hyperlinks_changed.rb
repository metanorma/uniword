# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module DocumentProperties
    # Hyperlinks changed flag
    #
    # Generated from OOXML schema: document_properties.yml
    # Element: <ep:HyperlinksChanged>
    class HyperlinksChanged < Lutaml::Model::Serializable
      attribute :content, String

      xml do
        element 'HyperlinksChanged'
        namespace Uniword::Ooxml::Namespaces::ExtendedProperties

        map_element '', to: :content, render_nil: false
      end
    end
  end
end
