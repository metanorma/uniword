# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Path gradient properties
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:path>
    class PathGradient < Lutaml::Model::Serializable
      attribute :path, String
      attribute :fill_to_rect, FillToRect

      xml do
        element 'path'
        namespace Uniword::Ooxml::Namespaces::DrawingML
        mixed_content

        map_attribute 'path', to: :path
        map_element 'fillToRect', to: :fill_to_rect, render_nil: false
      end
    end
  end
end
