# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Wordprocessingml
      # Level text format
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:lvlText>
      class LvlText < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            element 'lvlText'
            namespace Uniword::Ooxml::Namespaces::WordProcessingML

            map_attribute 'val', to: :val
          end
      end
    end
end
