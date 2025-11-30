# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Spreadsheetml
      # Drawing reference
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:drawing>
      class Drawing < Lutaml::Model::Serializable
          attribute :id, String

          xml do
            element 'drawing'
            namespace Uniword::Ooxml::Namespaces::SpreadsheetML

            map_attribute 'id', to: :id
          end
      end
    end
end
