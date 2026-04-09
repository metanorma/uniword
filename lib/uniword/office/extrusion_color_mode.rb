# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Office
    # Extrusion color mode
    #
    # Generated from OOXML schema: office.yml
    # Element: <o:extrusioncolormode>
    class ExtrusionColorMode < Lutaml::Model::Serializable
      attribute :mode, :string

      xml do
        element 'extrusioncolormode'
        namespace Uniword::Ooxml::Namespaces::Office

        map_attribute 'mode', to: :mode
      end
    end
  end
end
