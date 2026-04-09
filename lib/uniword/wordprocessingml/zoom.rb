# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Document zoom level
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:zoom>
    class Zoom < Lutaml::Model::Serializable
      attribute :percent, :integer

      xml do
        element 'zoom'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute 'percent', to: :percent
      end
    end
  end
end
