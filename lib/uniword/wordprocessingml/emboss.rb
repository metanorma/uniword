# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Wordprocessingml
      # Emboss text effect
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:emboss>
      class Emboss < Lutaml::Model::Serializable
          attribute :val, :boolean

          xml do
            element 'emboss'
            namespace Uniword::Ooxml::Namespaces::WordProcessingML

            map_attribute 'val', to: :val
          end
      end
    end
end
