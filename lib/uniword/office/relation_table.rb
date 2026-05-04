# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Office
    # Relationship table
    #
    # Generated from OOXML schema: office.yml
    # Element: <o:relationtable>
    class RelationTable < Lutaml::Model::Serializable
      attribute :data, :string

      xml do
        element "relationtable"
        namespace Uniword::Ooxml::Namespaces::Office

        map_content to: :data
      end
    end
  end
end
