# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Drawingml
    # Inverse gamma
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:invGamma>
    class InverseGamma < Lutaml::Model::Serializable
      xml do
        element "invGamma"
        namespace Uniword::Ooxml::Namespaces::DrawingML
      end
    end
  end
end
