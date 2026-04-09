# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Spreadsheetml
    # Pattern fill properties
    #
    # Generated from OOXML schema: spreadsheetml.yml
    # Element: <xls:patternFill>
    class PatternFill < Lutaml::Model::Serializable
      attribute :pattern_type, :string
      attribute :fg_color, Color
      attribute :bg_color, Color

      xml do
        element 'patternFill'
        namespace Uniword::Ooxml::Namespaces::SpreadsheetML
        mixed_content

        map_attribute 'pattern-type', to: :pattern_type
        map_element 'fgColor', to: :fg_color, render_nil: false
        map_element 'bgColor', to: :bg_color, render_nil: false
      end
    end
  end
end
