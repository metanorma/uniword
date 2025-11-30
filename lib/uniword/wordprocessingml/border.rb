# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml
    # Border formatting
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:border>
    class Border < Lutaml::Model::Serializable
      attribute :val, :string
      attribute :color, :string
      attribute :sz, :integer
      attribute :space, :integer
      attribute :shadow, :boolean

      xml do
        element 'border'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute 'val', to: :val
        map_attribute 'color', to: :color
        map_attribute 'sz', to: :sz
        map_attribute 'space', to: :space
        map_attribute 'shadow', to: :shadow
      end
    end
  end
end
