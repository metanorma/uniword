# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Spreadsheetml
      # Italic formatting
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:i>
      class Italic < Lutaml::Model::Serializable
          attribute :val, String

          xml do
            element 'i'
            namespace Uniword::Ooxml::Namespaces::SpreadsheetML

            map_attribute 'val', to: :val
          end
      end
    end
end
