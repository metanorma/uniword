# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Office
      # Regroup properties
      #
      # Generated from OOXML schema: office.yml
      # Element: <o:regroup>
      class Regroup < Lutaml::Model::Serializable
          attribute :id, String

          xml do
            root 'regroup'
            namespace 'urn:schemas-microsoft-com:office:office', 'o'

            map_attribute 'true', to: :id
          end
      end
    end
  end
end
