# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Close path command
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:close>
      class ClosePath < Lutaml::Model::Serializable


          xml do
            root 'close'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'

          end
      end
    end
  end
end
