# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module VmlOffice
    # Extension for complex VML properties
    #
    # Generated from OOXML schema: vml_office.yml
    # Element: <o:complexExtension>
    class VmlComplexExtension < Lutaml::Model::Serializable
      attribute :type, :string
      attribute :data, :string

      xml do
        element "complexExtension"
        namespace Uniword::Ooxml::Namespaces::Vml

        map_attribute "type", to: :type
        map_attribute "data", to: :data
      end
    end
  end
end
