# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Theme scheme color
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:schemeClr>
      class SchemeColor < Lutaml::Model::Serializable
          attribute :val, String

          xml do
            root 'schemeClr'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'

            map_attribute 'true', to: :val
          end
      end
    end
  end
end
