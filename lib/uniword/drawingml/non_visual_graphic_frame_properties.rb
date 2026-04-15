# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Drawingml
    # Non-visual graphic frame properties
    #
    # Element: <a:cNvGraphicFramePr>
    class NonVisualGraphicFrameProperties < Lutaml::Model::Serializable
      attribute :id, :string

      xml do
        element "cNvGraphicFramePr"
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute "id", to: :id
      end
    end
  end
end
