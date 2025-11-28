# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Office
      # Zoom level
      #
      # Generated from OOXML schema: office.yml
      # Element: <o:zoom>
      class Zoom < Lutaml::Model::Serializable
          attribute :percent, String

          xml do
            root 'zoom'
            namespace 'urn:schemas-microsoft-com:office:office', 'o'

            map_attribute 'true', to: :percent
          end
      end
    end
  end
end
