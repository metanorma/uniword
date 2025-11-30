# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Character spacing
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:spacing>
    class CharacterSpacing < Lutaml::Model::Serializable
      attribute :val, :integer

      xml do
        element 'spacing'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute 'val', to: :val
      end
    end
  end
end
