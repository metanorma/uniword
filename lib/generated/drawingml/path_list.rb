# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Path list
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:pathLst>
      class PathList < Lutaml::Model::Serializable
          attribute :paths, String, collection: true, default: -> { [] }

          xml do
            root 'pathLst'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'
            mixed_content

            map_element 'path', to: :paths, render_nil: false
          end
      end
    end
  end
end
