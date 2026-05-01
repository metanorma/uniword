# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    # Paragraph style reference for numbering
    #
    # Element: <w:pStyle>
    class PStyle < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "pStyle"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "val", to: :val
      end
    end

    # Tabs container for numbering level
    #
    # Element: <w:tabs>
    class Tabs < Lutaml::Model::Serializable
      attribute :tab, Tab, collection: true

      xml do
        element "tabs"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content
        map_element "tab", to: :tab, render_nil: false
      end
    end

    # Numbering level suffix type
    #
    # Element: <w:suff>
    class Suff < Lutaml::Model::Serializable
      attribute :val, :string

      xml do
        element "suff"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute "val", to: :val
      end
    end

    # Numbering level restart
    #
    # Element: <w:lvlRestart>
    class LvlRestart < Lutaml::Model::Serializable
      attribute :val, :integer

      xml do
        element "lvlRestart"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML

        map_attribute "val", to: :val
      end
    end

    # Numbering level definition
    #
    # Generated from OOXML schema: wordprocessingml.yml
    # Element: <w:lvl>
    class Level < Lutaml::Model::Serializable
      attribute :ilvl, :integer
      attribute :tentative, :string
      attribute :start, Start
      attribute :numFmt, NumFmt
      attribute :pStyle, PStyle
      attribute :suff, Suff
      attribute :lvlRestart, LvlRestart
      attribute :lvlText, LvlText
      attribute :lvlJc, LvlJc
      attribute :pPr, ParagraphProperties
      attribute :tabs, Tabs
      attribute :ind, Ind
      attribute :rPr, RunProperties

      xml do
        element "lvl"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        mixed_content

        map_attribute "ilvl", to: :ilvl
        map_attribute "tentative", to: :tentative, render_nil: false
        map_element "start", to: :start, render_nil: false
        map_element "numFmt", to: :numFmt, render_nil: false
        map_element "pStyle", to: :pStyle, render_nil: false
        map_element "suff", to: :suff, render_nil: false
        map_element "lvlRestart", to: :lvlRestart, render_nil: false
        map_element "lvlText", to: :lvlText, render_nil: false
        map_element "lvlJc", to: :lvlJc, render_nil: false
        map_element "pPr", to: :pPr, render_nil: false
        map_element "tabs", to: :tabs, render_nil: false
        map_element "ind", to: :ind, render_nil: false
        map_element "rPr", to: :rPr, render_nil: false
      end

      # Get level index (convenience method for numbering)
      def level_index
        ilvl
      end

      # Get numbering format value (convenience method)
      def format_value
        numFmt&.val
      end

      # Get start value (convenience method - returns integer)
      def start_value
        @start&.val
      end

      # Get alignment value (convenience method - returns string)
      def alignment_value
        lvlJc&.val
      end

      # Get left indent (convenience method - returns integer)
      def left_indent_value
        ind&.left&.to_i
      end

      # Get hanging indent (convenience method - returns integer)
      def hanging_indent_value
        ind&.hanging&.to_i
      end

      # Get level text value (convenience method - returns string)
      def text_value
        lvlText&.val
      end
    end
  end
end
