# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Drawingml
    # Preset dash pattern
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:prstDash>
    class PresetDash < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "prstDash"
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute "val", to: :val
      end
    end
  end
end
