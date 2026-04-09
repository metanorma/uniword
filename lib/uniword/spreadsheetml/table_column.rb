# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Spreadsheetml
    # Table column definition
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:tableColumn>
    class TableColumn < Lutaml::Model::Serializable
      attribute :id, :integer
      attribute :name, :string

      xml do
        element 'tableColumn'
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML

        map_attribute 'id', to: :id
        map_attribute 'name', to: :name
      end
    end
  end
end
