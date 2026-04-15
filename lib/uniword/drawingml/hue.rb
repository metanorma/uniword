# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Drawingml
    # Hue value
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:hue>
    class Hue < Lutaml::Model::Serializable
      attribute :val, :integer

      xml do
        element "hue"
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute "val", to: :val
      end
    end
  end
end
