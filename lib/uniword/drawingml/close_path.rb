# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Close path command
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:close>
    class ClosePath < Lutaml::Model::Serializable
      xml do
        element 'close'
        namespace Uniword::Ooxml::Namespaces::DrawingML
      end
    end
  end
end
