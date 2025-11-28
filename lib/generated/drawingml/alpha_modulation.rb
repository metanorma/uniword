# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Alpha modulation
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:alphaMod>
      class AlphaModulation < Lutaml::Model::Serializable
          attribute :val, Integer

          xml do
            root 'alphaMod'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'

            map_attribute 'true', to: :val
          end
      end
    end
  end
end
