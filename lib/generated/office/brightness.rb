# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Office
      # Brightness setting
      #
      # Generated from OOXML schema: office.yml
      # Element: <o:brightness>
      class Brightness < Lutaml::Model::Serializable
          attribute :value, String

          xml do
            root 'brightness'
            namespace 'urn:schemas-microsoft-com:office:office', 'o'

            map_attribute 'true', to: :value
          end
      end
    end
  end
end
