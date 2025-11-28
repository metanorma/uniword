# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Office
      # Callout shape properties
      #
      # Generated from OOXML schema: office.yml
      # Element: <o:callout>
      class Callout < Lutaml::Model::Serializable
          attribute :true, String
          attribute :type, String
          attribute :gap, String
          attribute :angle, String
          attribute :dropauto, String
          attribute :drop, String
          attribute :distance, String
          attribute :lengthspecified, String

          xml do
            root 'callout'
            namespace 'urn:schemas-microsoft-com:office:office', 'o'

            map_attribute 'true', to: :true
            map_attribute 'true', to: :type
            map_attribute 'true', to: :gap
            map_attribute 'true', to: :angle
            map_attribute 'true', to: :dropauto
            map_attribute 'true', to: :drop
            map_attribute 'true', to: :distance
            map_attribute 'true', to: :lengthspecified
          end
      end
    end
  end
end
