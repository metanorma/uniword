# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Simple 2D position
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:simplePos>
    class SimplePos < Lutaml::Model::Serializable
      attribute :x, :integer
      attribute :y, :integer

      xml do
        element 'simplePos'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute 'x', to: :x
        map_attribute 'y', to: :y
      end
    end
  end
end
