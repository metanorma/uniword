# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Wordprocessingml
      # Text position (raised/lowered)
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:position>
      class Position < Lutaml::Model::Serializable
          attribute :val, :integer

          xml do
            element 'position'
            namespace Uniword::Ooxml::Namespaces::WordProcessingML

            map_attribute 'val', to: :val
          end
      end
    end
end
