# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Grayscale effect
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:grayscl>
      class Grayscale < Lutaml::Model::Serializable


          xml do
            root 'grayscl'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'

          end
      end
    end
  end
end
