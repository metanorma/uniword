# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Gamma correction
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:gamma>
      class Gamma < Lutaml::Model::Serializable


          xml do
            root 'gamma'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'

          end
      end
    end
  end
end
