# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Office
    # Regroup table
    #
    # Generated from OOXML schema: office.yml
    # Element: <o:regrouptable>
    class RegroupTable < Lutaml::Model::Serializable
      attribute :data, :string

      xml do
        element "regrouptable"
        namespace Uniword::Ooxml::Namespaces::Office

        map_element "", to: :data, render_nil: false
      end
    end
  end
end
