# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Wordprocessingml
      # Tab stop definition
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:tabStop>
      class TabStop < Lutaml::Model::Serializable
          attribute :val, :string
          attribute :pos, :integer
          attribute :leader, :string

          xml do
            element 'tabStop'
            namespace Uniword::Ooxml::Namespaces::WordProcessingML

            map_attribute 'val', to: :val
            map_attribute 'pos', to: :pos
            map_attribute 'leader', to: :leader
          end
      end
    end
end
