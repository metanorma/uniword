# frozen_string_literal: true

require 'lutaml/model'

module Uniword
  module Generated
    module Wordprocessingml
      # Numbering level definition
      #
      # Generated from OOXML schema: wordprocessingml.yml
      # Element: <w:lvl>
      class Level < Lutaml::Model::Serializable
          attribute :ilvl, :integer
          attribute :start, Start
          attribute :numFmt, NumFmt
          attribute :lvlText, LvlText
          attribute :lvlJc, LvlJc
          attribute :pPr, ParagraphProperties
          attribute :rPr, RunProperties

          xml do
            root 'lvl'
            namespace 'http://schemas.openxmlformats.org/wordprocessingml/2006/main', 'w'
            mixed_content

            map_attribute 'true', to: :ilvl
            map_element 'start', to: :start, render_nil: false
            map_element 'numFmt', to: :numFmt, render_nil: false
            map_element 'lvlText', to: :lvlText, render_nil: false
            map_element 'lvlJc', to: :lvlJc, render_nil: false
            map_element 'pPr', to: :pPr, render_nil: false
            map_element 'rPr', to: :rPr, render_nil: false
          end
      end
    end
  end
end
