# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Drawingml
    # Arc to command
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:arcTo>
    class ArcTo < Lutaml::Model::Serializable
      attribute :wR, :string
      attribute :hR, :string
      attribute :stAng, :string
      attribute :swAng, :string

      xml do
        element "arcTo"
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute "wR", to: :wR
        map_attribute "hR", to: :hR
        map_attribute "stAng", to: :stAng
        map_attribute "swAng", to: :swAng
      end
    end
  end
end
