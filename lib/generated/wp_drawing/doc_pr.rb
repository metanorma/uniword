# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module WpDrawing
      # Drawing object non-visual properties
      #
      # Generated from OOXML schema: wp_drawing.yml
      # Element: <wp:docPr>
      class DocPr < Lutaml::Model::Serializable
          attribute :id, Integer
          attribute :name, String
          attribute :descr, String
          attribute :hidden, String
          attribute :title, String

          xml do
            root 'docPr'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing', 'wp'

            map_attribute 'true', to: :id
            map_attribute 'true', to: :name
            map_attribute 'true', to: :descr
            map_attribute 'true', to: :hidden
            map_attribute 'true', to: :title
          end
      end
    end
  end
end
