# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml2013
      # Presence information for real-time collaboration
      #
      # Generated from OOXML schema: wordprocessingml_2013.yml
      # Element: <w15:presenceInfo>
      class PresenceInfo < Lutaml::Model::Serializable
          attribute :provider_id, String
          attribute :user_id, String

          xml do
            root 'presenceInfo'
            namespace 'http://schemas.microsoft.com/office/word/2012/wordml', 'w15'

            map_attribute 'true', to: :provider_id
            map_attribute 'true', to: :user_id
          end
      end
    end
  end
end
