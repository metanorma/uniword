# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Office
      # Allow extrusion flag
      #
      # Generated from OOXML schema: office.yml
      # Element: <o:extrusionok>
      class ExtrusionOk < Lutaml::Model::Serializable
          attribute :value, String

          xml do
            root 'extrusionok'
            namespace 'urn:schemas-microsoft-com:office:office', 'o'

            map_attribute 'true', to: :value
          end
      end
    end
  end
end
