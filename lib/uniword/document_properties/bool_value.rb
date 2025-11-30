# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module DocumentProperties
    # Boolean value type
    #
    # Generated from OOXML schema: document_properties.yml
    # Element: <ep:bool>
    class BoolValue < Lutaml::Model::Serializable
      attribute :content, String

      xml do
        element 'bool'
        namespace Uniword::Ooxml::Namespaces::ExtendedProperties

        map_element '', to: :content, render_nil: false
      end
    end
  end
end
