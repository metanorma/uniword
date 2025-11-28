# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Office
      # Button control
      #
      # Generated from OOXML schema: office.yml
      # Element: <o:button>
      class Button < Lutaml::Model::Serializable
          attribute :type, String
          attribute :value, String
          attribute :caption, String

          xml do
            root 'button'
            namespace 'urn:schemas-microsoft-com:office:office', 'o'

            map_attribute 'true', to: :type
            map_attribute 'true', to: :value
            map_attribute 'true', to: :caption
          end
      end
    end
  end
end
