# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module VmlOffice
    # Right offset for VML elements
    #
    # Generated from OOXML schema: vml_office.yml
    # Element: <o:right>
    class VmlRight < Lutaml::Model::Serializable
      attribute :value, :string
      attribute :units, :string

      xml do
        element "right"
        namespace Uniword::Ooxml::Namespaces::Vml

        map_attribute "value", to: :value
        map_attribute "units", to: :units
      end
    end
  end
end
