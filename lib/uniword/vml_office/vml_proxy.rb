# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module VmlOffice
    # Proxy element for referencing
    #
    # Generated from OOXML schema: vml_office.yml
    # Element: <o:proxy>
    class VmlProxy < Lutaml::Model::Serializable
      attribute :start, :string
      attribute :end, :string
      attribute :idref, :string
      attribute :connectloc, :string

      xml do
        element "proxy"
        namespace Uniword::Ooxml::Namespaces::Vml

        map_attribute "start", to: :start
        map_attribute "end", to: :end
        map_attribute "idref", to: :idref
        map_attribute "connectloc", to: :connectloc
      end
    end
  end
end
