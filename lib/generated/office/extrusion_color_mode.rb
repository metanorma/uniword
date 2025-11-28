# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Office
      # Extrusion color mode
      #
      # Generated from OOXML schema: office.yml
      # Element: <o:extrusioncolormode>
      class ExtrusionColorMode < Lutaml::Model::Serializable
          attribute :mode, String

          xml do
            root 'extrusioncolormode'
            namespace 'urn:schemas-microsoft-com:office:office', 'o'

            map_attribute 'true', to: :mode
          end
      end
    end
  end
end
