# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Office
    # Metallic effect
    #
    # Generated from OOXML schema: office.yml
    # Element: <o:metal>
    class Metal < Lutaml::Model::Serializable
      attribute true, String

      xml do
        element 'metal'
        namespace Uniword::Ooxml::Namespaces::Office

        map_attribute 'true', to: true
      end
    end
  end
end
