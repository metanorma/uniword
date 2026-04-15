# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Drawingml
    # Alpha offset
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:alphaOff>
    class AlphaOffset < Lutaml::Model::Serializable
      attribute :val, :integer

      xml do
        element "alphaOff"
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute "val", to: :val
      end
    end
  end
end
