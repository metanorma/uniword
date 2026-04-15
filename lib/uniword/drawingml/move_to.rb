# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Drawingml
    # Move to command
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:moveTo>
    class MoveTo < Lutaml::Model::Serializable
      attribute :pt, :string

      xml do
        element "moveTo"
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_element "pt", to: :pt
      end
    end
  end
end
