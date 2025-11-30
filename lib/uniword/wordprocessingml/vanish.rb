# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Wordprocessingml
      # Hidden text
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:vanish>
      class Vanish < Lutaml::Model::Serializable
          attribute :val, :boolean

          xml do
            element 'vanish'
            namespace Uniword::Ooxml::Namespaces::WordProcessingML

            map_attribute 'val', to: :val
          end
      end
    end
end
