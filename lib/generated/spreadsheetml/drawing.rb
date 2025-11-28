# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Drawing reference
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:drawing>
      class Drawing < Lutaml::Model::Serializable
          attribute :id, String

          xml do
            root 'drawing'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'

            map_attribute 'true', to: :id
          end
      end
    end
  end
end
