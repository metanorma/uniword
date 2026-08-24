# frozen_string_literal: true

module Uniword
  module FindReplace
    # Abstract matcher: decides whether a string matches and what to
    # replace it with.
    #
    # Subclasses implement `matches?` (returns MatchData or nil) and
    # `substitute` (applies the replacement given MatchData). The
    # engine drives both via `apply`, which performs one substitution
    # pass over a single string and returns `[new_string, count]`.
    class Matcher
      # Apply the matcher to one string, replacing every non-overlapping
      # match. Returns the new string and the count of substitutions.
      #
      # @param text [String] the text to scan
      # @return [Array(String, Integer)] new text and substitution count
      def apply(text)
        raise NotImplementedError
      end
    end
  end
end
