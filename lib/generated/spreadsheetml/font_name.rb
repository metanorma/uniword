# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Font name
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:name>
      class FontName < Lutaml::Model::Serializable
          attribute :val, String

          xml do
            root 'name'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'

            map_attribute 'true', to: :val
          end
      end
    end
  end
end
