# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Graphic data holder
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:graphicData>
    class GraphicData < Lutaml::Model::Serializable
      attribute :uri, :string

      xml do
        element 'graphicData'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute 'uri', to: :uri
      end
    end
  end
end
