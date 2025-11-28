# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # OLE object definition
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:oleObject>
      class OleObject < Lutaml::Model::Serializable
          attribute :prog_id, String
          attribute :id, String

          xml do
            root 'oleObject'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'

            map_attribute 'true', to: :prog_id
            map_attribute 'true', to: :id
          end
      end
    end
  end
end
