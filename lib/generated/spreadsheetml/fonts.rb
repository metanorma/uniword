# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Font collection
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:fonts>
      class Fonts < Lutaml::Model::Serializable
          attribute :count, Integer
          attribute :font_entries, Font, collection: true, default: -> { [] }

          xml do
            root 'fonts'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'
            mixed_content

            map_attribute 'true', to: :count
            map_element 'font', to: :font_entries, render_nil: false
          end
      end
    end
  end
end
