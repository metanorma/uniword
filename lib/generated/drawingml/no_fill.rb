# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # No fill
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:noFill>
      class NoFill < Lutaml::Model::Serializable


          xml do
            root 'noFill'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'

          end
      end
    end
  end
end
