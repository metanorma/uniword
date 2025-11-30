# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Office
    # Extrusion color
    #
    # Generated from OOXML schema: office.yml
    # Element: <o:extrusioncolor>
    class ExtrusionColor < Lutaml::Model::Serializable
      attribute :color, String
      attribute :opacity, String

      xml do
        element 'extrusioncolor'
        namespace Uniword::Ooxml::Namespaces::Office

        map_attribute 'color', to: :color
        map_attribute 'opacity', to: :opacity
      end
    end
  end
end
