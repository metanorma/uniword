# frozen_string_literal: true

require "lutaml/model"

module Uniword
  module Properties
    # Font family element for run properties
    #
    # Represents <w:rFonts> with ascii, hAnsi, eastAsia, cs, hint attributes
    class RunFonts < Lutaml::Model::Serializable
      # Pattern 0: ATTRIBUTES FIRST
      attribute :ascii, :string
      attribute :h_ansi, :string
      attribute :east_asia, :string
      attribute :cs, :string
      attribute :hint, :string
      attribute :ascii_theme, :string
      attribute :east_asia_theme, :string
      attribute :h_ansi_theme, :string
      attribute :cs_theme, :string

      xml do
        element "rFonts"
        namespace Ooxml::Namespaces::WordProcessingML

        map_attribute "ascii", to: :ascii
        map_attribute "hAnsi", to: :h_ansi
        map_attribute "eastAsia", to: :east_asia
        map_attribute "cs", to: :cs
        map_attribute "hint", to: :hint
        map_attribute "asciiTheme", to: :ascii_theme
        map_attribute "eastAsiaTheme", to: :east_asia_theme
        map_attribute "hAnsiTheme", to: :h_ansi_theme
        map_attribute "cstheme", to: :cs_theme
      end
    end
  end
end
