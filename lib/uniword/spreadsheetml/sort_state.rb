# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Spreadsheetml
    # Sort state
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:sortState>
    class SortState < Lutaml::Model::Serializable
      attribute :ref, String

      xml do
        element 'sortState'
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML

        map_attribute 'ref', to: :ref
      end
    end
  end
end
