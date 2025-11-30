# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Wordprocessingml
      # Text highlight color
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:highlight>
      class Highlight < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            element 'highlight'
            namespace Uniword::Ooxml::Namespaces::WordProcessingML

            map_attribute 'val', to: :val
          end
      end
    end
end
