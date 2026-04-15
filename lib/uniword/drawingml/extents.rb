# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Drawingml
    # Shape extents
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:ext>
    class Extents < Lutaml::Model::Serializable
      attribute :cx, :integer
      attribute :cy, :integer

      xml do
        element "ext"
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute "cx", to: :cx
        map_attribute "cy", to: :cy
      end
    end
  end
end
