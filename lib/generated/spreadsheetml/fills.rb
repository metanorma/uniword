# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Fill collection
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:fills>
      class Fills < Lutaml::Model::Serializable
          attribute :count, Integer
          attribute :fill_entries, Fill, collection: true, default: -> { [] }

          xml do
            root 'fills'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'
            mixed_content

            map_attribute 'true', to: :count
            map_element 'fill', to: :fill_entries, render_nil: false
          end
      end
    end
  end
end
