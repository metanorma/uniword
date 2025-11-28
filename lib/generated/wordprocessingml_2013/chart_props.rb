# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml2013
      # Chart properties for embedded charts
      #
      # Generated from OOXML schema: wordprocessingml_2013.yml
      # Element: <w15:chartProps>
      class ChartProps < Lutaml::Model::Serializable
          attribute :style, String
          attribute :color_mapping, String

          xml do
            root 'chartProps'
            namespace 'http://schemas.microsoft.com/office/word/2012/wordml', 'w15'
            mixed_content

            map_attribute 'true', to: :style
            map_element 'colorMapping', to: :color_mapping, render_nil: false
          end
      end
    end
  end
end
