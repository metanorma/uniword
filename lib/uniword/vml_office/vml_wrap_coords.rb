# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module VmlOffice
    # Text wrap coordinates
    #
    # Generated from OOXML schema: vml_office.yml
    # Element: <o:wrapcoords>
    class VmlWrapCoords < Lutaml::Model::Serializable
      attribute :coords, :string

      xml do
        element "wrapcoords"
        namespace Uniword::Ooxml::Namespaces::Vml

        map_attribute "coords", to: :coords
      end
    end
  end
end
