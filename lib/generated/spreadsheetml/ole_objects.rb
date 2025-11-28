# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # OLE objects collection
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:oleObjects>
      class OleObjects < Lutaml::Model::Serializable
          attribute :objects, OleObject, collection: true, default: -> { [] }

          xml do
            root 'oleObjects'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'
            mixed_content

            map_element 'oleObject', to: :objects, render_nil: false
          end
      end
    end
  end
end
