# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Office
    # Regroup properties
    #
    # Generated from OOXML schema: office.yml
    # Element: <o:regroup>
    class Regroup < Lutaml::Model::Serializable
      attribute :id, :string

      xml do
        element "regroup"
        namespace Uniword::Ooxml::Namespaces::Office

        map_attribute "id", to: :id
      end
    end
  end
end
