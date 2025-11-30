# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Wordprocessingml
      # Base style reference
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:basedOn>
      class BasedOn < Lutaml::Model::Serializable
          attribute :val, :string

          xml do
            element 'basedOn'
            namespace Uniword::Ooxml::Namespaces::WordProcessingML

            map_attribute 'val', to: :val
          end
      end
    end
end
