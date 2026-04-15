# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Drawingml
    # Round line join
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:round>
    class LineJoinRound < Lutaml::Model::Serializable
      xml do
        element "round"
        namespace Uniword::Ooxml::Namespaces::DrawingML
      end
    end
  end
end
