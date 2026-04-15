# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Bibliography
    # Corporate author entity
    #
    # Generated from OOXML schema: bibliography.yml
    # Element: <b:corporate>
    class Corporate < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "corporate"
        namespace Uniword::Ooxml::Namespaces::Bibliography

        map_attribute "val", to: :val
      end
    end
  end
end
