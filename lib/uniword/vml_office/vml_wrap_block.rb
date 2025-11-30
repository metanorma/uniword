# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module VmlOffice
    # Text wrap block settings
    #
    # Generated from OOXML schema: vml_office.yml
    # Element: <o:wrapblock>
    class VmlWrapBlock < Lutaml::Model::Serializable
      attribute :type, String
      attribute :side, String

      xml do
        element 'wrapblock'
        namespace Uniword::Ooxml::Namespaces::Vml

        map_attribute 'type', to: :type
        map_attribute 'side', to: :side
      end
    end
  end
end
