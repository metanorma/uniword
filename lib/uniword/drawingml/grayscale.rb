# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Drawingml
    # Grayscale effect
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:grayscl>
    class Grayscale < Lutaml::Model::Serializable
      xml do
        element "grayscl"
        namespace Uniword::Ooxml::Namespaces::DrawingML
      end
    end
  end
end
