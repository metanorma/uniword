# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    class StructuredDocumentTag
      # Run properties for SDT content formatting
      # Reference XML: <w:rPr><w:caps/><w:color w:val="FFFFFF" w:themeColor="background1"/><w:sz w:val="32"/><w:szCs w:val="32"/></w:rPr>
      #
      # Uses mixed_content to preserve all child run property elements.
      # This is the same structure as Wordprocessingml::RunProperties but
      # scoped under the SDT namespace for autoload resolution.
      class RunProperties < Lutaml::Model::Serializable
        attribute :style, Properties::RunStyleReference, default: nil
        attribute :fonts, Properties::RunFonts, default: nil
        attribute :size, Properties::FontSize, default: nil
        attribute :size_cs, Properties::FontSize, default: nil
        attribute :color, Properties::ColorValue, default: nil
        attribute :bold, Properties::Bold, default: nil
        attribute :bold_cs, Properties::BoldCs, default: nil
        attribute :italic, Properties::Italic, default: nil
        attribute :italic_cs, Properties::ItalicCs, default: nil
        attribute :strike, Properties::Strike, default: nil
        attribute :double_strike, Properties::DoubleStrike, default: nil
        attribute :small_caps, Properties::SmallCaps, default: nil
        attribute :caps, Properties::Caps, default: nil
        attribute :hidden, Properties::Vanish, default: nil
        attribute :no_proof, Properties::NoProof, default: nil
        attribute :underline, Properties::Underline, default: nil
        attribute :highlight, Properties::Highlight, default: nil
        attribute :vertical_align, Properties::VerticalAlign, default: nil
        attribute :position, Properties::Position, default: nil
        attribute :character_spacing, Properties::CharacterSpacing, default: nil
        attribute :kerning, Properties::Kerning, default: nil
        attribute :width_scale, Properties::WidthScale, default: nil
        attribute :emphasis_mark, Properties::EmphasisMark, default: nil
        attribute :shading, Properties::Shading, default: nil
        attribute :language, Properties::Language, default: nil
        attribute :shadow, Properties::Shadow, default: nil
        attribute :emboss, Properties::Emboss, default: nil
        attribute :imprint, Properties::Imprint, default: nil
        attribute :outline, Properties::Outline, default: nil

        xml do
          element "rPr"
          namespace Ooxml::Namespaces::WordProcessingML
          mixed_content

          map_element "rStyle", to: :style, render_nil: false
          map_element "rFonts", to: :fonts, render_nil: false
          map_element "sz", to: :size, render_nil: false
          map_element "szCs", to: :size_cs, render_nil: false
          map_element "color", to: :color, render_nil: false
          map_element "b", to: :bold, render_nil: false
          map_element "bCs", to: :bold_cs, render_nil: false
          map_element "i", to: :italic, render_nil: false
          map_element "iCs", to: :italic_cs, render_nil: false
          map_element "strike", to: :strike, render_nil: false
          map_element "dstrike", to: :double_strike, render_nil: false
          map_element "smallCaps", to: :small_caps, render_nil: false
          map_element "caps", to: :caps, render_nil: false
          map_element "vanish", to: :hidden, render_nil: false
          map_element "noProof", to: :no_proof, render_nil: false
          map_element "u", to: :underline, render_nil: false
          map_element "highlight", to: :highlight, render_nil: false
          map_element "vertAlign", to: :vertical_align, render_nil: false
          map_element "position", to: :position, render_nil: false
          map_element "spacing", to: :character_spacing, render_nil: false
          map_element "kern", to: :kerning, render_nil: false
          map_element "w", to: :width_scale, render_nil: false
          map_element "em", to: :emphasis_mark, render_nil: false
          map_element "shd", to: :shading, render_nil: false
          map_element "lang", to: :language, render_nil: false
          map_element "shadow", to: :shadow, render_nil: false
          map_element "emboss", to: :emboss, render_nil: false
          map_element "imprint", to: :imprint, render_nil: false
          map_element "outline", to: :outline, render_nil: false
        end
      end
    end
  end
end
