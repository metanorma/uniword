# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module VmlOffice
    # Regrouping settings
    #
    # Generated from OOXML schema: vml_office.yml
    # Element: <o:regroup>
    class VmlRegroup < Lutaml::Model::Serializable
      attribute :id, :string

      xml do
        element "regroup"
        namespace Uniword::Ooxml::Namespaces::Vml

        map_attribute "id", to: :id
      end
    end
  end
end
