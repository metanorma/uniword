# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Red modulation
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:redMod>
    class RedModulation < Lutaml::Model::Serializable
      attribute :val, :integer

      xml do
        element 'redMod'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute 'val', to: :val
      end
    end
  end
end
