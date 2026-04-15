# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Office
    # Skew transformation
    #
    # Generated from OOXML schema: office.yml
    # Element: <o:skew>
    class Skew < Lutaml::Model::Serializable
      attribute true, :string
      attribute :offset, :string
      attribute :origin, :string
      attribute :matrix, :string

      xml do
        element "skew"
        namespace Uniword::Ooxml::Namespaces::Office

        map_attribute "true", to: true
        map_attribute "offset", to: :offset
        map_attribute "origin", to: :origin
        map_attribute "matrix", to: :matrix
      end
    end
  end
end
