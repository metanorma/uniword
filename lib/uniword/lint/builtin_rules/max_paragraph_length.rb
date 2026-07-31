# frozen_string_literal: true

module Uniword
  module Lint
    module BuiltinRules
      # Rule: paragraphs longer than `max` words trigger a finding.
      class MaxParagraphLength < Rule
        register :max_paragraph_length, self

        # @param max [Integer] word count threshold (default 200)
        def initialize(max: 200, **rest)
          super(**rest)
          @max = max
        end

        def check(document)
          document.paragraphs.each_with_index do |paragraph, idx|
            text = paragraph.text.to_s
            word_count = text.split.length
            next if word_count <= @max

            yield finding(
              message: "Paragraph #{idx + 1} has #{word_count} words " \
                       "(max #{@max})",
              path: "paragraph[#{idx}]",
            )
          end
        end
      end
    end
  end
end
