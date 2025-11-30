# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Blue component
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:blue>
    class Blue < Lutaml::Model::Serializable
      attribute :val, :integer

      xml do
        element 'blue'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute 'val', to: :val
      end
    end
  end
end
