# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Drawingml
    # Red offset
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:redOff>
    class RedOffset < Lutaml::Model::Serializable
      attribute :val, :integer

      xml do
        element "redOff"
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute "val", to: :val
      end
    end
  end
end
