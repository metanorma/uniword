# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Imprint text effect
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:imprint>
    class Imprint < Lutaml::Model::Serializable
      attribute :val, :boolean

      xml do
        element 'imprint'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute 'val', to: :val
      end
    end
  end
end
