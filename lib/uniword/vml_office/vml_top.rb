# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module VmlOffice
    # Top offset for VML elements
    #
    # Generated from OOXML schema: vml_office.yml
    # Element: <o:top>
    class VmlTop < Lutaml::Model::Serializable
      attribute :value, :string
      attribute :units, :string

      xml do
        element "top"
        namespace Uniword::Ooxml::Namespaces::Vml

        map_attribute "value", to: :value
        map_attribute "units", to: :units
      end
    end
  end
end
