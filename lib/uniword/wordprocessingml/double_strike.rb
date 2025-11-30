# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Wordprocessingml
      # Double strikethrough formatting
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:dstrike>
      class DoubleStrike < Lutaml::Model::Serializable
          attribute :val, :boolean

          xml do
            element 'dstrike'
            namespace Uniword::Ooxml::Namespaces::WordProcessingML

            map_attribute 'val', to: :val
          end
      end
    end
end
