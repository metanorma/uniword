# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Fixed alpha modulation
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:alphaModFix>
    class AlphaModulationFixed < Lutaml::Model::Serializable
      attribute :amt, Integer

      xml do
        element 'alphaModFix'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute 'amt', to: :amt
      end
    end
  end
end
