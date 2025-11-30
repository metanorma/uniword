# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Small caps formatting
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:smallCaps>
    class SmallCaps < Lutaml::Model::Serializable
      attribute :val, :boolean

      xml do
        element 'smallCaps'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute 'val', to: :val
      end
    end
  end
end
