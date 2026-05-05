# frozen_string_literal: true

module Uniword
  module Docx
    # Calculates document statistics that appear in docProps/app.xml.
    #
    # Verified against Microsoft Word 2024. Rules:
    #   - Words: whitespace-separated tokens; each CJK char = 1 word
    #   - Characters: total chars minus whitespace (NO paragraph marks)
    #   - CharactersWithSpaces: total chars including spaces (NO paragraph marks)
    #   - Paragraphs: count of non-empty paragraphs (empty paras excluded)
    #   - Lines: same as non-empty paragraph count (no page layout engine)
    #   - Pages: simple approximation (no page layout engine)
    #
    # Known limitations:
    #   - Pages and Lines use paragraph-based approximation (no page layout engine)
    #   - Footnote/endnote text is not included (unclear if Word includes it)
    #   - Header/footer text is not included (Word likely excludes it)
    class DocumentStatistics
      # CJK Unified Ideographs and extension ranges
      CJK_REGEX = /[\u4E00-\u9FFF\u3400-\u4DBF\uF900-\uFAFF\u2F00-\u2FDF\u2E80-\u2EFF]/
      WHITESPACE_REGEX = /[ \t\r\n]/

      def initialize(package)
        @package = package
      end

      # @return [Hash{Symbol => Integer}]
      def calculate
        body = @package.document&.body
        return empty_stats unless body

        text_per_paragraph = []
        collect_text(body, text_per_paragraph)

        # Word only counts non-empty paragraphs
        non_empty = text_per_paragraph.reject { |t| t.strip.empty? }

        {
          pages: estimate_pages(non_empty.size),
          words: count_words(non_empty),
          characters: count_characters_no_spaces(non_empty),
          characters_with_spaces: count_characters_with_spaces(non_empty),
          paragraphs: non_empty.size,
          lines: estimate_lines(non_empty.size),
        }
      end

      private

      # Recursively collect text from paragraphs, tables, and SDTs.
      def collect_text(container, text_per_paragraph)
        if container.respond_to?(:paragraphs)
          container.paragraphs.each do |para|
            text_per_paragraph << para.text
          end
        end

        if container.respond_to?(:tables)
          container.tables.each do |table|
            table.rows.each do |row|
              row.cells.each do |cell|
                collect_text(cell, text_per_paragraph)
              end
            end
          end
        end

        if container.respond_to?(:structured_document_tags)
          container.structured_document_tags.each do |sdt|
            sdt.content&.paragraphs&.each do |para|
              text = para.text
              text_per_paragraph << text
            end
          end
        end
      end

      # Count words using Word's algorithm:
      # - Whitespace-separated tokens for Latin text
      # - Each CJK character counts as 1 word individually
      # - Mixed CJK/Latin segments are counted appropriately
      def count_words(text_per_paragraph)
        total = 0
        text_per_paragraph.each do |text|
          next if text.strip.empty?

          # Split text into CJK and non-CJK segments
          segments = text.scan(/[\u4E00-\u9FFF\u3400-\u4DBF\uF900-\uFAFF\u2F00-\u2FDF\u2E80-\u2EFF]+|[^ \t\r\n]+/)
          segments.each do |seg|
            total += if seg.match?(CJK_REGEX)
                       seg.length
                     else
                       seg.split(/\s+/).reject(&:empty?).size
                     end
          end
        end
        total
      end

      # Characters (no spaces) = total chars minus whitespace.
      #
      # Verified against Word 2024:
      #   "Hello World" → 10 (not 11, no paragraph marks)
      def count_characters_no_spaces(text_per_paragraph)
        total_chars = text_per_paragraph.sum(&:length)
        whitespace_count = text_per_paragraph.sum { |t| t.count(" \t") }
        total_chars - whitespace_count
      end

      # Characters (with spaces) = total chars including spaces.
      #
      # Verified against Word 2024:
      #   "Hello World" → 11
      def count_characters_with_spaces(text_per_paragraph)
        text_per_paragraph.sum(&:length)
      end

      # Page estimation without page layout engine.
      # Uses a simple heuristic: ~45 paragraphs per page.
      def estimate_pages(paragraph_count)
        [1, (paragraph_count / 45.0).ceil].max
      end

      # Line estimation without page layout engine.
      def estimate_lines(paragraph_count)
        [1, paragraph_count].max
      end

      def empty_stats
        {
          pages: 1,
          words: 0,
          characters: 0,
          characters_with_spaces: 0,
          paragraphs: 0,
          lines: 1,
        }
      end
    end
  end
end
