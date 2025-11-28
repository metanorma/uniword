# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Named range definition
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:definedName>
      class DefinedName < Lutaml::Model::Serializable
          attribute :name, String
          attribute :comment, String
          attribute :local_sheet_id, Integer
          attribute :hidden, String

          xml do
            root 'definedName'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'

            map_attribute 'true', to: :name
            map_attribute 'true', to: :comment
            map_attribute 'true', to: :local_sheet_id
            map_attribute 'true', to: :hidden
          end
      end
    end
  end
end
