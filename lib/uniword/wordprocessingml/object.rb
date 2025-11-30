# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Embedded object
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:object>
    class Object < Lutaml::Model::Serializable
      attribute :dxaOrig, :integer
      attribute :dyaOrig, :integer

      xml do
        element 'object'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute 'dxaOrig', to: :dxaOrig
        map_attribute 'dyaOrig', to: :dyaOrig
      end
    end
  end
end
