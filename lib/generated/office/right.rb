# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Office
      # Right position
      #
      # Generated from OOXML schema: office.yml
      # Element: <o:right>
      class Right < Lutaml::Model::Serializable
          attribute :value, String

          xml do
            root 'right'
            namespace 'urn:schemas-microsoft-com:office:office', 'o'

            map_attribute 'true', to: :value
          end
      end
    end
  end
end
