# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Wordprocessingml
      # Abstract numbering ID reference
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:abstractNumId>
      class AbstractNumId < Lutaml::Model::Serializable
          attribute :val, :integer

          xml do
            element 'abstractNumId'
            namespace Uniword::Ooxml::Namespaces::WordProcessingML

            map_attribute 'val', to: :val
          end
      end
    end
end
