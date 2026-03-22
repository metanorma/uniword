# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Spreadsheetml
    # OLE objects collection
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:oleObjects>
    class OleObjects < Lutaml::Model::Serializable
      attribute :objects, OleObject, collection: true, initialize_empty: true

      xml do
        element 'oleObjects'
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML
        mixed_content

        map_element 'oleObject', to: :objects, render_nil: false
      end
    end
  end
end
