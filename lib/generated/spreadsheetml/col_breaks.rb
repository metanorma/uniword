# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Column page breaks
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:colBreaks>
      class ColBreaks < Lutaml::Model::Serializable
          attribute :count, Integer
          attribute :breaks, String, collection: true, default: -> { [] }

          xml do
            root 'colBreaks'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'
            mixed_content

            map_attribute 'true', to: :count
            map_element 'brk', to: :breaks, render_nil: false
          end
      end
    end
  end
end
