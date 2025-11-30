# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Alpha transparency
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:alpha>
    class Alpha < Lutaml::Model::Serializable
      attribute :val, Integer

      xml do
        element 'alpha'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute 'val', to: :val
      end
    end
  end
end
