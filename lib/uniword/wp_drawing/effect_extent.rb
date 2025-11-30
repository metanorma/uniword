# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module WpDrawing
    # Object effect extent (shadow/glow space)
    #
    # Generated from OOXML schema: wp_drawing.yml
    # Element: <wp:effectExtent>
    class EffectExtent < Lutaml::Model::Serializable
      attribute :l, :integer
      attribute :t, :integer
      attribute :r, :integer
      attribute :b, :integer

      xml do
        element 'effectExtent'
        namespace Uniword::Ooxml::Namespaces::WordProcessingDrawing

        map_attribute 'l', to: :l
        map_attribute 't', to: :t
        map_attribute 'r', to: :r
        map_attribute 'b', to: :b
      end
    end
  end
end
