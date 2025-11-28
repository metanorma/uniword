# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Drawingml
      # Level 1 paragraph properties
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:lvl1pPr>
      class Level1ParagraphProperties < Lutaml::Model::Serializable
          attribute :algn, String
          attribute :def_tab_sz, Integer

          xml do
            root 'lvl1pPr'
            namespace 'http://schemas.openxmlformats.org/drawingml/2006/main', 'a'

            map_attribute 'true', to: :algn
            map_attribute 'true', to: :def_tab_sz
          end
      end
    end
  end
end
