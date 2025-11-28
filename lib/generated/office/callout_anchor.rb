# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Office
      # Callout anchor point
      #
      # Generated from OOXML schema: office.yml
      # Element: <o:calloutanchor>
      class CalloutAnchor < Lutaml::Model::Serializable
          attribute :position, String

          xml do
            root 'calloutanchor'
            namespace 'urn:schemas-microsoft-com:office:office', 'o'

            map_attribute 'true', to: :position
          end
      end
    end
  end
end
