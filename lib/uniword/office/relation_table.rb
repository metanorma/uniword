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

        map_element "", to: :data, render_nil: false
      end
    end
  end
end
