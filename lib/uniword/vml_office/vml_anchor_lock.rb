# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module VmlOffice
      # Anchor lock to prevent movement
      #
      # Generated from OOXML schema: vml_office.yml
      # Element: <o:anchorlock>
      class VmlAnchorLock < Lutaml::Model::Serializable
          attribute :locked, String

          xml do
            element 'anchorlock'
            namespace Uniword::Ooxml::Namespaces::Vml

            map_attribute 'locked', to: :locked
          end
      end
    end
end
