# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module WpDrawing
      # Display object behind document text
      #
      # Generated from OOXML schema: wp_drawing.yml
      # Element: <wp:behindDoc>
      class BehindDoc < Lutaml::Model::Serializable
          attribute :value, String

          xml do
            root 'behindDoc'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing', 'wp'

            map_element '', to: :value, render_nil: false
          end
      end
    end
  end
end
