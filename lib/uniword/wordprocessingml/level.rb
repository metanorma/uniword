# frozen_string_literal: true

require 'lutaml/model'
require_relative '../ooxml/wordprocessingml/paragraph_properties'
require_relative '../ooxml/wordprocessingml/run_properties'

module Uniword
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
      attribute :pPr, Uniword::Ooxml::WordProcessingML::ParagraphProperties
      attribute :rPr, Uniword::Ooxml::WordProcessingML::RunProperties

      xml do
        element 'lvl'
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_attribute 'ilvl', to: :ilvl
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
