# frozen_string_literal: true

require 'lutaml/model'

module Uniword
    module Drawingml
      # List style
      #
      # Generated from OOXML schema: drawingml.yml
      # Element: <a:lstStyle>
      class ListStyle < Lutaml::Model::Serializable
          attribute :def_p_pr, DefaultParagraphProperties
          attribute :lvl1_p_pr, Level1ParagraphProperties
          attribute :lvl2_p_pr, Level2ParagraphProperties
          attribute :lvl3_p_pr, Level3ParagraphProperties

          xml do
            element 'lstStyle'
            namespace Uniword::Ooxml::Namespaces::DrawingML
            mixed_content

            map_element 'defPPr', to: :def_p_pr, render_nil: false
            map_element 'lvl1pPr', to: :lvl1_p_pr, render_nil: false
            map_element 'lvl2pPr', to: :lvl2_p_pr, render_nil: false
            map_element 'lvl3pPr', to: :lvl3_p_pr, render_nil: false
          end
      end
    end
end
