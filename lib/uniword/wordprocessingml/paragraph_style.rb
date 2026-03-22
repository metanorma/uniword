# frozen_string_literal: true

module Uniword
  module Wordprocessingml
    # Factory class for creating paragraph Style instances
    #
    # Provides factory methods for common paragraph styles like
    # Normal, Heading1-9, etc.
    class ParagraphStyle
      # Create a Normal paragraph style
      #
      # @return [Style] Normal style instance
      def self.normal
        Style.new(
          type: 'paragraph',
          styleId: 'Normal',
          default: true,
          name: StyleName.new(val: 'Normal'),
          qFormat: Properties::QuickFormat.new
        )
      end

      # Create a Heading style for the given level
      #
      # @param level [Integer] Heading level (1-9)
      # @return [Style] Heading style instance
      def self.heading(level)
        raise ArgumentError, "Heading level must be 1-9" unless (1..9).cover?(level)

        Style.new(
          type: 'paragraph',
          styleId: "Heading#{level}",
          name: StyleName.new(val: "Heading #{level}"),
          basedOn: BasedOn.new(val: 'Normal'),
          nextStyle: Next.new(val: 'Normal'),
          uiPriority: UiPriority.new(val: (level + 8).to_s),
          qFormat: Properties::QuickFormat.new,
          pPr: create_heading_paragraph_properties(level),
          rPr: create_heading_run_properties(level)
        )
      end

      # Create a Title style
      #
      # @return [Style] Title style instance
      def self.title
        Style.new(
          type: 'paragraph',
          styleId: 'Title',
          name: StyleName.new(val: 'Title'),
          basedOn: BasedOn.new(val: 'Normal'),
          nextStyle: Next.new(val: 'Normal'),
          uiPriority: UiPriority.new(val: '10'),
          qFormat: Properties::QuickFormat.new,
          rPr: RunProperties.new(
            size: Properties::FontSize.new(val: '56'),
            fonts: Properties::RunFonts.new(ascii: 'Calibri Light', h_ansi: 'Calibri Light')
          )
        )
      end

      # Create a Subtitle style
      #
      # @return [Style] Subtitle style instance
      def self.subtitle
        Style.new(
          type: 'paragraph',
          styleId: 'Subtitle',
          name: StyleName.new(val: 'Subtitle'),
          basedOn: BasedOn.new(val: 'Normal'),
          nextStyle: Next.new(val: 'Normal'),
          uiPriority: UiPriority.new(val: '11'),
          qFormat: Properties::QuickFormat.new,
          rPr: RunProperties.new(
            color: Properties::ColorValue.new(val: '595959'),
            size: Properties::FontSize.new(val: '28'),
            fonts: Properties::RunFonts.new(ascii: 'Calibri Light', h_ansi: 'Calibri Light')
          )
        )
      end

      # Create a Quote style
      #
      # @return [Style] Quote style instance
      def self.quote
        Style.new(
          type: 'paragraph',
          styleId: 'Quote',
          name: StyleName.new(val: 'Quote'),
          basedOn: BasedOn.new(val: 'Normal'),
          nextStyle: Next.new(val: 'Normal'),
          uiPriority: UiPriority.new(val: '29'),
          qFormat: Properties::QuickFormat.new,
          pPr: ParagraphProperties.new(
            indentation: Properties::Indentation.new(left: '720')
          ),
          rPr: RunProperties.new(
            italic: Properties::Italic.new
          )
        )
      end

      # Create an Intense Quote style
      #
      # @return [Style] Intense Quote style instance
      def self.intense_quote
        Style.new(
          type: 'paragraph',
          styleId: 'IntenseQuote',
          name: StyleName.new(val: 'Intense Quote'),
          basedOn: BasedOn.new(val: 'Quote'),
          nextStyle: Next.new(val: 'Normal'),
          uiPriority: UiPriority.new(val: '30'),
          qFormat: Properties::QuickFormat.new,
          rPr: RunProperties.new(
            bold: Properties::Bold.new
          )
        )
      end

      private

      # Create paragraph properties for heading styles
      #
      # @param level [Integer] Heading level
      # @return [ParagraphProperties] Paragraph properties
      def self.create_heading_paragraph_properties(level)
        outline_level = [level - 1, 0].max

        ParagraphProperties.new(
          outline_level: Properties::OutlineLevel.new(val: outline_level.to_s),
          spacing: Properties::Spacing.new(before: (240 + (level * 80)).to_s, after: '0')
        )
      end

      # Create run properties for heading styles
      #
      # @param level [Integer] Heading level
      # @return [RunProperties] Run properties
      def self.create_heading_run_properties(level)
        sizes = {
          1 => '32', 2 => '26', 3 => '24', 4 => '22', 5 => '20',
          6 => '20', 7 => '20', 8 => '20', 9 => '20'
        }
        fonts = {
          1 => 'Calibri Light', 2 => 'Calibri Light', 3 => 'Calibri',
          4 => 'Calibri', 5 => 'Calibri', 6 => 'Calibri',
          7 => 'Calibri', 8 => 'Calibri', 9 => 'Calibri'
        }
        colors = {
          1 => '2E74B5', 2 => '2E74B5', 3 => '1F4E79',
          4 => '2E74B5', 5 => '2E74B5', 6 => '1F3763',
          7 => '2E74B5', 8 => '2E74B5', 9 => '2E74B5'
        }

        RunProperties.new(
          size: Properties::FontSize.new(val: sizes[level]),
          fonts: Properties::RunFonts.new(ascii: fonts[level], h_ansi: fonts[level]),
          color: Properties::ColorValue.new(val: colors[level]),
          bold: Properties::Bold.new
        )
      end
    end
  end
end
