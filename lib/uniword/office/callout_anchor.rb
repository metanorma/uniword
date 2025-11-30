# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Office
    # Callout anchor point
    #
    # Generated from OOXML schema: office.yml
    # Element: <o:calloutanchor>
    class CalloutAnchor < Lutaml::Model::Serializable
      attribute :position, String

      xml do
        element 'calloutanchor'
        namespace Uniword::Ooxml::Namespaces::Office

        map_attribute 'position', to: :position
      end
    end
  end
end
