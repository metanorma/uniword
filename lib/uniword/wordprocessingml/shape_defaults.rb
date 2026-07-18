# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    class ShapeDefaults < Lutaml::Model::Serializable
      attribute :shape_defaults, Uniword::VmlOffice::VmlShapeDefaults
      attribute :shape_layout, Uniword::VmlOffice::VmlShapeLayout

      xml do
        element "shapeDefaults"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content
        map_element "shapedefaults", to: :shape_defaults, render_nil: false
        map_element "shapelayout", to: :shape_layout, render_nil: false
      end
    end
  end
end
