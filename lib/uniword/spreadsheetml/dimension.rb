# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Spreadsheetml
      # Sheet dimensions
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:dimension>
      class Dimension < Lutaml::Model::Serializable
          attribute :ref, String

          xml do
            element 'dimension'
            namespace Uniword::Ooxml::Namespaces::SpreadsheetML

            map_attribute 'ref', to: :ref
          end
      end
    end
end
