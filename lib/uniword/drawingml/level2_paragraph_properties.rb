# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Drawingml
    # Level 2 paragraph properties
    #
    # Generated from OOXML schema: drawingml.yml
    # Element: <a:lvl2pPr>
    class Level2ParagraphProperties < Lutaml::Model::Serializable
      attribute :algn, :string
      attribute :def_tab_sz, :integer

      xml do
        element "lvl2pPr"
        namespace Uniword::Ooxml::Namespaces::DrawingML

        map_attribute "algn", to: :algn
        map_attribute "def-tab-sz", to: :def_tab_sz
      end
    end
  end
end
