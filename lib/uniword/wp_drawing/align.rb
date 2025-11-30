# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module WpDrawing
    # Alignment type
    #
    # Generated from OOXML schema: wp_drawing.yml
    # Element: <wp:align>
    class Align < Lutaml::Model::Serializable
      attribute :value, :string

      xml do
        element 'align'
        namespace Uniword::Ooxml::Namespaces::WordProcessingDrawing

        map_element '', to: :value, render_nil: false
      end
    end
  end
end
