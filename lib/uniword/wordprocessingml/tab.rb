# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Tab character with attributes
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:tab>
    class Tab < Lutaml::Model::Serializable
      attribute :val, :string
      attribute :pos, :string

      xml do
        element 'tab'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute 'val', to: :val
        map_attribute 'pos', to: :pos
      end
    end
  end
end
