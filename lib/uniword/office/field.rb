# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Office
    # Field properties
    #
    # Generated from OOXML schema: office.yml
    # Element: <o:field>
    class Field < Lutaml::Model::Serializable
      attribute :type, :string
      attribute :data, :string

      xml do
        element "field"
        namespace Uniword::Ooxml::Namespaces::Office

        map_attribute "type", to: :type
        map_attribute "data", to: :data
      end
    end
  end
end
