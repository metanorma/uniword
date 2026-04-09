# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Drawingml
    # Preset geometry shape
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:prstGeom>
    class PresetGeometry < Lutaml::Model::Serializable
      attribute :prst, :string
      attribute :av_lst, AdjustValueList

      xml do
        element 'prstGeom'
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute 'prst', to: :prst
        map_element 'avLst', to: :av_lst, render_nil: false
      end
    end
  end
end
