# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Path list
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:pathLst>
    class PathList < Lutaml::Model::Serializable
      attribute :paths, :string, collection: true, initialize_empty: true

      xml do
        element 'pathLst'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_element 'path', to: :paths, render_nil: false
      end
    end
  end
end
