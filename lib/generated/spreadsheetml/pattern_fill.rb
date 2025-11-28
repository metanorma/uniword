# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Pattern fill properties
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:patternFill>
      class PatternFill < Lutaml::Model::Serializable
          attribute :pattern_type, String
          attribute :fg_color, Color
          attribute :bg_color, Color

          xml do
            root 'patternFill'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'
            mixed_content

            map_attribute 'true', to: :pattern_type
            map_element 'fgColor', to: :fg_color, render_nil: false
            map_element 'bgColor', to: :bg_color, render_nil: false
          end
      end
    end
  end
end
