# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Border collection
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:borders>
      class Borders < Lutaml::Model::Serializable
          attribute :count, Integer
          attribute :border_entries, Border, collection: true, default: -> { [] }

          xml do
            root 'borders'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'
            mixed_content

            map_attribute 'true', to: :count
            map_element 'border', to: :border_entries, render_nil: false
          end
      end
    end
  end
end
