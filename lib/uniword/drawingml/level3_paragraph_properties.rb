# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Drawingml
      # Level 3 paragraph properties
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:lvl3pPr>
      class Level3ParagraphProperties < Lutaml::Model::Serializable
          attribute :algn, String
          attribute :def_tab_sz, Integer

          xml do
            element 'lvl3pPr'
            namespace Uniword::Ooxml::Namespaces::DrawingML

            map_attribute 'algn', to: :algn
            map_attribute 'def-tab-sz', to: :def_tab_sz
          end
      end
    end
end
