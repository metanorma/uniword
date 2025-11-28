# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Stretch fill to shape bounds
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:stretch>
      class Stretch < Lutaml::Model::Serializable


          xml do
            root 'stretch'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'

          end
      end
    end
  end
end
