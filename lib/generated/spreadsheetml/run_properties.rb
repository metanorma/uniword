# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Rich text run properties
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:rPr>
      class RunProperties < Lutaml::Model::Serializable
          attribute :sz, FontSize
          attribute :color, Color
          attribute :b, Bold
          attribute :i, Italic

          xml do
            root 'rPr'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'
            mixed_content

            map_element 'sz', to: :sz, render_nil: false
            map_element 'color', to: :color, render_nil: false
            map_element 'b', to: :b, render_nil: false
            map_element 'i', to: :i, render_nil: false
          end
      end
    end
  end
end
