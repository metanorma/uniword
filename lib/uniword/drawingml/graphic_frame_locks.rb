# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Drawingml
    # Graphic frame locks
    # Used to specify locking properties for a graphic frame
    class GraphicFrameLocks < Lutaml::Model::Serializable
      attribute :no_change_aspect, :string
      attribute :no_change_shape_type, :string
      attribute :extensibility, :string

      xml do
        element "graphicFrameLocks"
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute "noChangeAspect", to: :no_change_aspect
        map_attribute "noChangeShapeType", to: :no_change_shape_type
        map_attribute "extensibility", to: :extensibility
      end
    end
  end
end
