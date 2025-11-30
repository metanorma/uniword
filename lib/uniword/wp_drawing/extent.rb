# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module WpDrawing
    # Drawing object size extent
    #
    # Generated from OOXML schema: wp_drawing.yml
    # Element: <wp:extent>
    class Extent < Lutaml::Model::Serializable
      attribute :cx, :integer
      attribute :cy, :integer

      xml do
        element 'extent'
        namespace Uniword::Ooxml::Namespaces::WordProcessingDrawing

        map_attribute 'cx', to: :cx
        map_attribute 'cy', to: :cy
      end
    end
  end
end
