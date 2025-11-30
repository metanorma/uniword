# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Gamma correction
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:gamma>
    class Gamma < Lutaml::Model::Serializable
      xml do
        element 'gamma'
        namespace Uniword::Ooxml::Namespaces::DrawingML
      end
    end
  end
end
