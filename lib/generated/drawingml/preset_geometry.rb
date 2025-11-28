# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Preset geometry shape
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:prstGeom>
      class PresetGeometry < Lutaml::Model::Serializable
          attribute :prst, String
          attribute :av_lst, AdjustValueList

          xml do
            root 'prstGeom'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'
            mixed_content

            map_attribute 'true', to: :prst
            map_element 'avLst', to: :av_lst, render_nil: false
          end
      end
    end
  end
end
