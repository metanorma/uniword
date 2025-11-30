# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Spreadsheetml
    # Pivot cache definitions
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:pivotCaches>
    class PivotCaches < Lutaml::Model::Serializable
      attribute :caches, :string, collection: true, default: -> { [] }

      xml do
        element 'pivotCaches'
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML
        mixed_content

        map_element 'pivotCache', to: :caches, render_nil: false
      end
    end
  end
end
