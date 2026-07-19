# frozen_string_literal: true

module Uniword
  module Wordprocessingml
    # Replaces one font family with another across a document —
    # Word's Home → Replace → Replace Fonts as an API.
    #
    # Covers style definitions and defaults, body content (paragraphs,
    # tables, hyperlinks), headers and footers, footnotes, endnotes,
    # comments, and numbering levels. Theme font references
    # (asciiTheme/hAnsiTheme/...) are NOT rewritten — those are
    # controlled by the theme's font scheme
    # (see DocumentRoot#apply_font_scheme).
    #
    # @example Replace Calibri with Carlito throughout a document
    #   replacer = FontReplacer.new(from: "Calibri", to: "Carlito")
    #   replacer.replace(document)
    #   puts replacer.count # number of rFonts values rewritten
    class FontReplacer
      # RunFonts attributes rewritten by font replacement.
      FONT_ATTRIBUTES = %i[ascii h_ansi east_asia cs].freeze

      # Create a replacer.
      #
      # @param from [String] Font family to replace (exact match,
      #   Word semantics)
      # @param to [String] Replacement font family
      def initialize(from:, to:)
        @from = from.to_s
        @to = to.to_s
        @count = 0
      end

      # Number of rFonts attribute values replaced so far.
      #
      # @return [Integer] Replacement count
      attr_reader :count

      # Replace @from with @to throughout the document (mutated).
      #
      # @param document [DocumentRoot] Document to rewrite
      # @return [Integer] Replacement count
      def replace(document)
        replace_in_styles(document.styles_configuration)
        replace_in_numbering(document.numbering_configuration)
        replace_in_container(document.body)
        part_containers(document).each do |container|
          replace_in_paragraphs(container)
        end
        count
      end

      private

      # Styles: docDefaults and every style definition.
      def replace_in_styles(styles)
        return unless styles

        replace_in_run_properties(styles.doc_defaults&.rPrDefault&.rPr)
        (styles.styles || []).each do |style|
          replace_in_run_properties(style.rPr)
        end
      end

      # Numbering: every level of every abstract definition.
      def replace_in_numbering(numbering)
        return unless numbering

        (numbering.definitions || []).each do |definition|
          (definition.levels || []).each do |level|
            replace_in_run_properties(level.rPr)
          end
        end
      end

      # Containers outside the body: header/footer parts, note
      # entries, and comments — model objects holding paragraphs.
      def part_containers(document)
        header_footer_containers(document) +
          note_containers(document) + comment_containers(document)
      end

      def header_footer_containers(document)
        (document.header_footer_parts || []).filter_map do |part|
          part.content if part.content.is_a?(Lutaml::Model::Serializable)
        end
      end

      def note_containers(document)
        (document.footnotes&.footnote_entries || []) +
          (document.endnotes&.endnote_entries || [])
      end

      def comment_containers(document)
        document.comments&.comments || []
      end

      # Walk a container's paragraphs, recursing into (nested) tables.
      def replace_in_container(container)
        return unless container

        replace_in_paragraphs(container)
        (container.tables || []).each { |table| replace_in_table(table) }
      end

      def replace_in_table(table)
        (table.rows || []).each do |row|
          (row.cells || []).each { |cell| replace_in_container(cell) }
        end
      end

      # Walk only paragraphs — for note/comment/header/footer parts,
      # whose models do not expose nested tables.
      def replace_in_paragraphs(container)
        (container.paragraphs || []).each do |paragraph|
          replace_in_paragraph(paragraph)
        end
      end

      def replace_in_paragraph(paragraph)
        replace_in_runs(paragraph.runs)
        (paragraph.hyperlinks || []).each do |hyperlink|
          replace_in_runs(hyperlink.runs)
        end
      end

      def replace_in_runs(runs)
        (runs || []).each do |run|
          replace_in_run_properties(run.properties)
        end
      end

      # Rewrite matching RunFonts attribute values in place.
      def replace_in_run_properties(run_properties)
        fonts = run_properties&.fonts
        return unless fonts

        FONT_ATTRIBUTES.each do |attr|
          next unless fonts.method(attr).call == @from

          fonts.method(:"#{attr}=").call(@to)
          @count += 1
        end
      end
    end
  end
end
