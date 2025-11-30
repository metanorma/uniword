# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Drawingml
      # Level 1 paragraph properties
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:lvl1pPr>
      class Level1ParagraphProperties < Lutaml::Model::Serializable
          attribute :algn, String
          attribute :def_tab_sz, Integer

          xml do
            element 'lvl1pPr'
            namespace Uniword::Ooxml::Namespaces::DrawingML

            map_attribute 'algn', to: :algn
            map_attribute 'def-tab-sz', to: :def_tab_sz
          end
      end
    end
end
