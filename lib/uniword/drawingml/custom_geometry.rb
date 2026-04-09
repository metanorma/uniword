# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Custom geometry
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:custGeom>
    class CustomGeometry < Lutaml::Model::Serializable
      attribute :av_lst, AdjustValueList
      attribute :path_lst, PathList

      xml do
        element 'custGeom'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_element 'avLst', to: :av_lst, render_nil: false
        map_element 'pathLst', to: :path_lst
      end
    end
  end
end
