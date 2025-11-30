# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module WpDrawing
      # Display object behind document text
      #
      # Generated from OOXML schema: wp_drawing.yml
      # Element: <wp:behindDoc>
      class BehindDoc < Lutaml::Model::Serializable
          attribute :value, String

          xml do
            element 'behindDoc'
            namespace Uniword::Ooxml::Namespaces::WordProcessingDrawing

            map_element '', to: :value, render_nil: false
          end
      end
    end
end
