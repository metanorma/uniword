# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Fill overlay effect
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:fillOverlay>
      class FillOverlay < Lutaml::Model::Serializable
          attribute :blend, String

          xml do
            root 'fillOverlay'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'

            map_attribute 'true', to: :blend
          end
      end
    end
  end
end
