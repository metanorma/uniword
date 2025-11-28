# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Office
      # Skew transformation
      #
      # Generated from OOXML schema: office.yml
      # Element: <o:skew>
      class Skew < Lutaml::Model::Serializable
          attribute :true, String
          attribute :offset, String
          attribute :origin, String
          attribute :matrix, String

          xml do
            root 'skew'
            namespace 'urn:schemas-microsoft-com:office:office', 'o'

            map_attribute 'true', to: :true
            map_attribute 'true', to: :offset
            map_attribute 'true', to: :origin
            map_attribute 'true', to: :matrix
          end
      end
    end
  end
end
