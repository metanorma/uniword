# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module WpDrawing
    # Position offset in EMUs
    #
    # Generated from OOXML schema: wp_drawing.yml
    # Element: <wp:posOffset>
    class PosOffset < Lutaml::Model::Serializable
      attribute :value, :integer

      xml do
        element 'posOffset'
        namespace Uniword::Ooxml::Namespaces::WordProcessingDrawing

        map_element '', to: :value, render_nil: false
      end
    end
  end
end
