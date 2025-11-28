# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Fixed alpha modulation
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:alphaModFix>
      class AlphaModulationFixed < Lutaml::Model::Serializable
          attribute :amt, Integer

          xml do
            root 'alphaModFix'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'

            map_attribute 'true', to: :amt
          end
      end
    end
  end
end
