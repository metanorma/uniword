# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module VmlOffice
      # Anchor lock to prevent movement
      #
      # Generated from OOXML schema: vml_office.yml
      # Element: <o:anchorlock>
      class VmlAnchorLock < Lutaml::Model::Serializable
          attribute :locked, String

          xml do
            root 'anchorlock'
            namespace 'urn:schemas-microsoft-com:vml', 'o'

            map_attribute 'true', to: :locked
          end
      end
    end
  end
end
