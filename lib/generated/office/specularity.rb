# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Office
      # Specularity value
      #
      # Generated from OOXML schema: office.yml
      # Element: <o:specularity>
      class Specularity < Lutaml::Model::Serializable
          attribute :value, String

          xml do
            root 'specularity'
            namespace 'urn:schemas-microsoft-com:office:office', 'o'

            map_attribute 'true', to: :value
          end
      end
    end
  end
end
