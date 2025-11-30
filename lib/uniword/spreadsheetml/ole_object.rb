# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Spreadsheetml
    # OLE object definition
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:oleObject>
    class OleObject < Lutaml::Model::Serializable
      attribute :prog_id, String
      attribute :id, String

      xml do
        element 'oleObject'
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML

        map_attribute 'prog-id', to: :prog_id
        map_attribute 'id', to: :id
      end
    end
  end
end
