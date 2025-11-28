# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Simple 2D position
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:simplePos>
      class SimplePos < Lutaml::Model::Serializable
          attribute :x, :integer
          attribute :y, :integer

          xml do
            root 'simplePos'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'

            map_attribute 'true', to: :x
            map_attribute 'true', to: :y
          end
      end
    end
  end
end
