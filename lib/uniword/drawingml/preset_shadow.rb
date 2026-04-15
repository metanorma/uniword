# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Drawingml
    # Preset shadow effect
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:prstShdw>
    class PresetShadow < Lutaml::Model::Serializable
      attribute :prst, :string
      attribute :dist, :integer
      attribute :dir, :integer

      xml do
        element "prstShdw"
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute "prst", to: :prst
        map_attribute "dist", to: :dist
        map_attribute "dir", to: :dir
      end
    end
  end
end
