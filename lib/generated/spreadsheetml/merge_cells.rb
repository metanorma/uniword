# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Merged cells collection
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:mergeCells>
      class MergeCells < Lutaml::Model::Serializable
          attribute :count, Integer
          attribute :cells, MergeCell, collection: true, default: -> { [] }

          xml do
            root 'mergeCells'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'
            mixed_content

            map_attribute 'true', to: :count
            map_element 'mergeCell', to: :cells, render_nil: false
          end
      end
    end
  end
end
