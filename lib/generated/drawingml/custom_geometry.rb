# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Custom geometry
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:custGeom>
      class CustomGeometry < Lutaml::Model::Serializable
          attribute :av_lst, AdjustValueList
          attribute :path_lst, PathList

          xml do
            root 'custGeom'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'
            mixed_content

            map_element 'avLst', to: :av_lst, render_nil: false
            map_element 'pathLst', to: :path_lst
          end
      end
    end
  end
end
