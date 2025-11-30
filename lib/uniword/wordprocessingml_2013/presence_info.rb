# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Wordprocessingml2013
    # Presence information for real-time collaboration
    #
    # Generated from OOXML schema: wordprocessingml_2013.yml
    # Element: <w15:presenceInfo>
    class PresenceInfo < Lutaml::Model::Serializable
      attribute :provider_id, :string
      attribute :user_id, :string

      xml do
        element 'presenceInfo'
        namespace Uniword::Ooxml::Namespaces::Word2012

        map_attribute 'provider-id', to: :provider_id
        map_attribute 'user-id', to: :user_id
      end
    end
  end
end
