# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Fill definition
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:fill>
      class Fill < Lutaml::Model::Serializable
          attribute :pattern_fill, PatternFill

          xml do
            root 'fill'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'
            mixed_content

            map_element 'patternFill', to: :pattern_fill, render_nil: false
          end
      end
    end
  end
end
