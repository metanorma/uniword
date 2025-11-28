# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Office
      # Metallic effect
      #
      # Generated from OOXML schema: office.yml
      # Element: <o:metal>
      class Metal < Lutaml::Model::Serializable
          attribute :true, String

          xml do
            root 'metal'
            namespace 'urn:schemas-microsoft-com:office:office', 'o'

            map_attribute 'true', to: :true
          end
      end
    end
  end
end
