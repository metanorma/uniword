# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Theme scheme color
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:schemeClr>
    class SchemeColor < Lutaml::Model::Serializable
      attribute :val, String

      xml do
        element 'schemeClr'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute 'val', to: :val
      end
    end
  end
end
