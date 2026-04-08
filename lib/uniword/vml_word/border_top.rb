# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module VmlWord
    # VML top border element
    #
    # Element: <w:bordertop>
    class BorderTop < Lutaml::Model::Serializable
      attribute :type, :string
      attribute :width, :string
      attribute :shadow, :string
      attribute :space, :string
      attribute :color, :string

      xml do
        element 'bordertop'
        namespace Uniword::Ooxml::Namespaces::VmlWord

        map_attribute 'type', to: :type
        map_attribute 'w:width', to: :width
        map_attribute 'shadow', to: :shadow
        map_attribute 'space', to: :space
        map_attribute 'color', to: :color
      end
    end
  end
end
