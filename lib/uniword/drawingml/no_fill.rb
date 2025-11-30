# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # No fill
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:noFill>
    class NoFill < Lutaml::Model::Serializable
      xml do
        element 'noFill'
        namespace Uniword::Ooxml::Namespaces::DrawingML
      end
    end
  end
end
