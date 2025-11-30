# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Wordprocessingml
      # All caps formatting
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:caps>
      class Caps < Lutaml::Model::Serializable
          attribute :val, :boolean

          xml do
            element 'caps'
            namespace Uniword::Ooxml::Namespaces::WordProcessingML

            map_attribute 'val', to: :val
          end
      end
    end
end
