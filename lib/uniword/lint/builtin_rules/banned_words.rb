# frozen_string_literal: true

require "set"

module Uniword
  module Lint
    module BuiltinRules
      # Rule: paragraphs containing banned words trigger a finding.
      class BannedWords < Rule
        register :banned_words, self

        # @param words [Array<String>] words to flag
        def initialize(words:, **rest)
          super(**rest)
          @banned = Set.new(Array(words).map(&:downcase))
        end

        def check(document)
          document.paragraphs.each_with_index do |paragraph, idx|
            text = paragraph.text.to_s.downcase
            @banned.each do |word|
              next unless text.match?(/\b#{Regexp.escape(word)}\b/)

              yield finding(
                message: "Paragraph #{idx + 1} contains banned word " \
                         "'#{word}'",
                path: "paragraph[#{idx}]",
              )
            end
          end
        end
      end
    end
  end
end
