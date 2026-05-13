# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Wordprocessingml
    class StylePaneFormatFilter < Lutaml::Model::Serializable
      attribute :val, :string
      attribute :all_styles, :string
      attribute :custom_styles, :string
      attribute :latent_styles, :string
      attribute :styles_in_use, :string
      attribute :heading_styles, :string
      attribute :numbering_styles, :string
      attribute :table_styles, :string
      attribute :direct_formatting_on_runs, :string
      attribute :direct_formatting_on_paragraphs, :string
      attribute :direct_formatting_on_numbering, :string
      attribute :direct_formatting_on_tables, :string
      attribute :clear_formatting, :string
      attribute :top3_heading_styles, :string
      attribute :visible_styles, :string
      attribute :alternate_style_names, :string

      xml do
        element "stylePaneFormatFilter"
        namespace Uniword::Ooxml::Namespaces::WordProcessingML
        map_attribute "val", to: :val
        map_attribute "allStyles", to: :all_styles
        map_attribute "customStyles", to: :custom_styles
        map_attribute "latentStyles", to: :latent_styles
        map_attribute "stylesInUse", to: :styles_in_use
        map_attribute "headingStyles", to: :heading_styles
        map_attribute "numberingStyles", to: :numbering_styles
        map_attribute "tableStyles", to: :table_styles
        map_attribute "directFormattingOnRuns", to: :direct_formatting_on_runs
        map_attribute "directFormattingOnParagraphs",
                      to: :direct_formatting_on_paragraphs
        map_attribute "directFormattingOnNumbering",
                      to: :direct_formatting_on_numbering
        map_attribute "directFormattingOnTables",
                      to: :direct_formatting_on_tables
        map_attribute "clearFormatting", to: :clear_formatting
        map_attribute "top3HeadingStyles", to: :top3_heading_styles
        map_attribute "visibleStyles", to: :visible_styles
        map_attribute "alternateStyleNames", to: :alternate_style_names
      end
    end
  end
end
