# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Pivot cache definitions
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:pivotCaches>
      class PivotCaches < Lutaml::Model::Serializable
          attribute :caches, String, collection: true, default: -> { [] }

          xml do
            root 'pivotCaches'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'
            mixed_content

            map_element 'pivotCache', to: :caches, render_nil: false
          end
      end
    end
  end
end
