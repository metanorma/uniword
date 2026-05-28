# frozen_string_literal: true

module Uniword
  module Docx
    class DocumentStatistics
      CJK_REGEX = /[一-鿿㐀-䶿豈-﫿⼀-⿟⺀-⻿]/
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
        collect_notes(text_per_paragraph)
        collect_headers_footers(text_per_paragraph)

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

      def collect_text(body, text_per_paragraph)
        collect_paragraphs(body.paragraphs, text_per_paragraph)
        collect_table_text(body.tables, text_per_paragraph)
        collect_sdt_text(body.structured_document_tags, text_per_paragraph)
      end

      def collect_paragraphs(paragraphs, text_per_paragraph)
        paragraphs.each { |para| text_per_paragraph << para.text }
      end

      def collect_table_text(tables, text_per_paragraph)
        tables.each do |table|
          table.rows.each do |row|
            row.cells.each do |cell|
              collect_paragraphs(cell.paragraphs, text_per_paragraph)
              collect_table_text(cell.tables, text_per_paragraph)
            end
          end
        end
      end

      def collect_sdt_text(sdts, text_per_paragraph)
        sdts.each do |sdt|
          next unless sdt.content
          collect_paragraphs(sdt.content.paragraphs, text_per_paragraph)
        end
      end

      def collect_notes(text_per_paragraph)
        @package.footnotes&.footnote_entries&.each do |entry|
          entry.paragraphs.each { |p| text_per_paragraph << p.text }
        end
        @package.endnotes&.endnote_entries&.each do |entry|
          entry.paragraphs.each { |p| text_per_paragraph << p.text }
        end
      end

      def collect_headers_footers(text_per_paragraph)
        @package.document&.headers&.each_value do |header|
          header.paragraphs.each { |p| text_per_paragraph << p.text }
        end
        @package.document&.footers&.each_value do |footer|
          footer.paragraphs.each { |p| text_per_paragraph << p.text }
        end
      end

      def count_words(text_per_paragraph)
        total = 0
        text_per_paragraph.each do |text|
          next if text.strip.empty?

          segments = text.scan(/[一-鿿㐀-䶿豈-﫿⼀-⿟⺀-⻿]+|[^ \t\r\n]+/)
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

      def count_characters_no_spaces(text_per_paragraph)
        total_chars = text_per_paragraph.sum(&:length)
        whitespace_count = text_per_paragraph.sum { |t| t.count(" \t") }
        total_chars - whitespace_count
      end

      def count_characters_with_spaces(text_per_paragraph)
        text_per_paragraph.sum(&:length)
      end

      def estimate_pages(paragraph_count)
        [1, (paragraph_count / 45.0).ceil].max
      end

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
