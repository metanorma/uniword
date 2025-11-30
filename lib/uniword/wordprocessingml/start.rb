# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Wordprocessingml
      # Numbering start value
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:start>
      class Start < Lutaml::Model::Serializable
          attribute :val, :integer

          xml do
            element 'start'
            namespace Uniword::Ooxml::Namespaces::WordProcessingML

            map_attribute 'val', to: :val
          end
      end
    end
end
