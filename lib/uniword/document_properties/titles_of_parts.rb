# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module DocumentProperties
    # Vector of part titles
    #
    # Generated from OOXML schema: document_properties.yml
    # Element: <ep:TitlesOfParts>
    class TitlesOfParts < Lutaml::Model::Serializable
      attribute :vector, Vector

      xml do
        element 'TitlesOfParts'
        namespace Uniword::Ooxml::Namespaces::ExtendedProperties
        mixed_content

        map_element 'vector', to: :vector, render_nil: false
      end
    end
  end
end
