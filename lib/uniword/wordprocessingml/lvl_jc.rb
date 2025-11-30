# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Wordprocessingml
      # Level justification
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:lvlJc>
      class LvlJc < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            element 'lvlJc'
            namespace Uniword::Ooxml::Namespaces::WordProcessingML

            map_attribute 'val', to: :val
          end
      end
    end
end
