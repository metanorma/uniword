# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Drawingml
    # Green component
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:green>
    class Green < Lutaml::Model::Serializable
      attribute :val, :integer

      xml do
        element "green"
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute "val", to: :val
      end
    end
  end
end
