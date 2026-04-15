# frozen_string_literal: true

module Uniword
  module Wordprocessingml
    # Factory class for creating character Style instances
    #
    # Provides factory methods for common character styles like
    # DefaultParagraphFont, Emphasis, Strong, etc.
    class CharacterStyle
      # Create the default character style
      #
      # @return [Style] Default character style instance
      def self.default_char
        Style.new(
          type: "character",
          styleId: "DefaultParagraphFont",
          name: StyleName.new(val: "Default Paragraph Font"),
          default: true
        )
      end

      # Create an Emphasis character style (italic)
      #
      # @return [Style] Emphasis style instance
      def self.emphasis
        Style.new(
          type: "character",
          styleId: "Emphasis",
          name: StyleName.new(val: "Emphasis"),
          customStyle: true,
          rPr: RunProperties.new(
            italic: Properties::Italic.new
          )
        )
      end

      # Create a Strong character style (bold)
      #
      # @return [Style] Strong style instance
      def self.strong
        Style.new(
          type: "character",
          styleId: "Strong",
          name: StyleName.new(val: "Strong"),
          customStyle: true,
          rPr: RunProperties.new(
            bold: Properties::Bold.new
          )
        )
      end

      # Create a Subtle Emphasis character style
      #
      # @return [Style] Subtle Emphasis style instance
      def self.subtle_emphasis
        Style.new(
          type: "character",
          styleId: "SubtleEmphasis",
          name: StyleName.new(val: "Subtle Emphasis"),
          customStyle: true,
          rPr: RunProperties.new(
            italic: Properties::Italic.new,
            color: Properties::ColorValue.new(val: "595959")
          )
        )
      end

      # Create an Intense Emphasis character style
      #
      # @return [Style] Intense Emphasis style instance
      def self.intense_emphasis
        Style.new(
          type: "character",
          styleId: "IntenseEmphasis",
          name: StyleName.new(val: "Intense Emphasis"),
          customStyle: true,
          rPr: RunProperties.new(
            italic: Properties::Italic.new,
            bold: Properties::Bold.new,
            color: Properties::ColorValue.new(val: "2E74B5")
          )
        )
      end

      # Create a Quote character style
      #
      # @return [Style] Quote character style instance
      def self.quote_char
        Style.new(
          type: "character",
          styleId: "QuoteChar",
          name: StyleName.new(val: "Quote Char"),
          basedOn: BasedOn.new(val: "DefaultParagraphFont"),
          customStyle: true,
          rPr: RunProperties.new(
            italic: Properties::Italic.new
          )
        )
      end

      # Create an Intense Quote character style
      #
      # @return [Style] Intense Quote character style instance
      def self.intense_quote_char
        Style.new(
          type: "character",
          styleId: "IntenseQuoteChar",
          name: StyleName.new(val: "Intense Quote Char"),
          basedOn: BasedOn.new(val: "DefaultParagraphFont"),
          customStyle: true,
          rPr: RunProperties.new(
            italic: Properties::Italic.new,
            bold: Properties::Bold.new
          )
        )
      end

      # Create a Subtle Reference character style
      #
      # @return [Style] Subtle Reference style instance
      def self.subtle_reference
        Style.new(
          type: "character",
          styleId: "SubtleReference",
          name: StyleName.new(val: "Subtle Reference"),
          customStyle: true,
          rPr: RunProperties.new(
            italic: Properties::Italic.new,
            color: Properties::ColorValue.new(val: "595959")
          )
        )
      end

      # Create an Intense Reference character style
      #
      # @return [Style] Intense Reference style instance
      def self.intense_reference
        Style.new(
          type: "character",
          styleId: "IntenseReference",
          name: StyleName.new(val: "Intense Reference"),
          customStyle: true,
          rPr: RunProperties.new(
            bold: Properties::Bold.new,
            color: Properties::ColorValue.new(val: "2E74B5")
          )
        )
      end

      # Create a Book Title character style
      #
      # @return [Style] Book Title style instance
      def self.book_title
        Style.new(
          type: "character",
          styleId: "BookTitle",
          name: StyleName.new(val: "Book Title"),
          customStyle: true,
          rPr: RunProperties.new(
            italic: Properties::Italic.new,
            fonts: Properties::RunFonts.new(ascii: "Constantia", h_ansi: "Constantia")
          )
        )
      end

      # Create a Hyperlink character style
      #
      # @return [Style] Hyperlink style instance
      def self.hyperlink
        Style.new(
          type: "character",
          styleId: "Hyperlink",
          name: StyleName.new(val: "Hyperlink"),
          customStyle: true,
          rPr: RunProperties.new(
            color: Properties::ColorValue.new(val: "0000FF"),
            underline: Properties::Underline.new(val: "single")
          )
        )
      end

      # Create a Followed Hyperlink character style
      #
      # @return [Style] Followed Hyperlink style instance
      def self.followed_hyperlink
        Style.new(
          type: "character",
          styleId: "FollowedHyperlink",
          name: StyleName.new(val: "Followed Hyperlink"),
          customStyle: true,
          rPr: RunProperties.new(
            color: Properties::ColorValue.new(val: "800080"),
            underline: Properties::Underline.new(val: "single")
          )
        )
      end
    end
  end
end
