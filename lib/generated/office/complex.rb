# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Office
      # Complex property
      #
      # Generated from OOXML schema: office.yml
      # Element: <o:complex>
      class Complex < Lutaml::Model::Serializable
          attribute :ext, String

          xml do
            root 'complex'
            namespace 'urn:schemas-microsoft-com:office:office', 'o'

            map_attribute 'true', to: :ext
          end
      end
    end
  end
end
