# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Spreadsheetml
      # Font definition
      #
      # Generated from OOXML schema: spreadsheetml.yml
      # Element: <xls:font>
      class Font < Lutaml::Model::Serializable
          attribute :sz, FontSize
          attribute :name, FontName
          attribute :b, Bold
          attribute :i, Italic
          attribute :color, Color

          xml do
            root 'font'
            namespace 'http://schemas.openxmlformats.org/spreadsheetml/2006/main', 'xls'
            mixed_content

            map_element 'sz', to: :sz, render_nil: false
            map_element 'name', to: :name, render_nil: false
            map_element 'b', to: :b, render_nil: false
            map_element 'i', to: :i, render_nil: false
            map_element 'color', to: :color, render_nil: false
          end
      end
    end
  end
end
