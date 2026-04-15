# frozen_string_literal: true

module Uniword
  module Quality
    # Checks paragraph word count for readability.
    #
    # Responsibility: Validate paragraph length.
    # Single Responsibility - only checks paragraph word count.
    #
    # Validates:
    # - Paragraphs don't exceed maximum word count
    # - Warns when paragraphs approach warning threshold
    # - Promotes readability and scannability
    #
    # @example Configuration
    #   paragraph_length:
    #     enabled: true
    #     max_words: 500
    #     warning_words: 400
    class ParagraphLengthRule < QualityRule
      def initialize(config = {})
        super
        @max_words = @config[:max_words] || 500
        @warning_words = @config[:warning_words] || 400
      end

      # Check document for paragraph length violations
      #
      # @param document [Document] The document to check
      # @return [Array<QualityViolation>] List of violations found
      def check(document)
        violations = []

        document.paragraphs.each_with_index do |para, index|
          word_count = count_words(para)

          # Skip empty paragraphs
          next if word_count.zero?

          if word_count > @max_words
            violations << create_violation(
              severity: :error,
              message: "Paragraph has #{word_count} words (maximum: #{@max_words}). " \
                       "Consider breaking into smaller paragraphs for readability.",
              location: "Paragraph #{index + 1}",
              element: para
            )
          elsif word_count > @warning_words
            violations << create_violation(
              severity: :warning,
              message: "Paragraph has #{word_count} words (warning threshold: #{@warning_words}). " \
                       "Consider reviewing for clarity.",
              location: "Paragraph #{index + 1}",
              element: para
            )
          end
        end

        violations
      end

      private

      # Count words in a paragraph
      #
      # @param paragraph [Paragraph] The paragraph to count words in
      # @return [Integer] Word count
      def count_words(paragraph)
        text = paragraph.text
        return 0 if text.nil? || text.empty?

        # Split on whitespace and count non-empty elements
        text.split(/\s+/).reject(&:empty?).count
      end
    end
  end
end
