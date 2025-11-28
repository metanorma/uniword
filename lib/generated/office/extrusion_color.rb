# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Office
      # Extrusion color
      #
      # Generated from OOXML schema: office.yml
      # Element: <o:extrusioncolor>
      class ExtrusionColor < Lutaml::Model::Serializable
          attribute :color, String
          attribute :opacity, String

          xml do
            root 'extrusioncolor'
            namespace 'urn:schemas-microsoft-com:office:office', 'o'

            map_attribute 'true', to: :color
            map_attribute 'true', to: :opacity
          end
      end
    end
  end
end
