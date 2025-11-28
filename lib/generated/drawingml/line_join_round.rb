# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Round line join
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:round>
      class LineJoinRound < Lutaml::Model::Serializable


          xml do
            root 'round'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'

          end
      end
    end
  end
end
