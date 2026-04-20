# frozen_string_literal: true

require "open3"

module Uniword
  module Spellcheck
    # Thin wrapper around the hunspell command-line spell checker.
    #
    # Responsibility: Interface with the hunspell binary for spell
    # checking and suggestion retrieval.
    #
    # @example Check a word
    #   adapter = HunspellAdapter.new(language: "en_US")
    #   adapter.check("hello")  #=> true
    #   adapter.check("helo")   #=> false
    #
    # @example Get suggestions
    #   adapter.suggest("helo")  #=> ["hello", "helot", ...]
    class HunspellAdapter
      attr_reader :language

      # Initialize the hunspell adapter.
      #
      # @param language [String] Dictionary language (default: "en_US")
      # @raise [DependencyError] if hunspell binary is not found
      def initialize(language: "en_US")
        @language = language
        verify_hunspell!
      end

      # Check whether a word is spelled correctly.
      #
      # @param word [String] The word to check
      # @return [Boolean] true if word is correct, false otherwise
      def check(word)
        return true if word.strip.empty?
        return true unless word.match?(/\p{L}/)

        stdout, _stderr, _status = Open3.capture3(
          "hunspell", "-d", language, "-l",
          stdin_data: "#{word}\n"
        )
        stdout.strip.empty?
      end

      # Get spelling suggestions for a word.
      #
      # @param word [String] The word to get suggestions for
      # @return [Array<String>] Array of suggested corrections
      def suggest(word)
        return [] if word.strip.empty?
        return [] unless word.match?(/\p{L}/)

        stdout, _stderr, _status = Open3.capture3(
          "hunspell", "-d", language, "-a",
          stdin_data: "#{word}\n"
        )
        parse_suggestions(stdout)
      end

      private

      # Verify hunspell is available on the system.
      #
      # @raise [DependencyError] if hunspell is not installed
      def verify_hunspell!
        _stdout, _stderr, status = Open3.capture3("which", "hunspell")
        return if status.success?

        raise DependencyError.new(
          "hunspell",
          "spell checking"
        )
      end

      # Parse hunspell pipe-mode output for suggestions.
      #
      # Hunspell pipe mode returns lines like:
      #   & word count offset: suggest1, suggest2, ...
      #
      # @param output [String] Raw hunspell output
      # @return [Array<String>] Parsed suggestions
      def parse_suggestions(output)
        suggestions = []
        output.each_line do |line|
          next unless line.start_with?("&")

          # Format: & original count offset: suggest1, suggest2, ...
          _prefix, rest = line.split(": ", 2)
          next unless rest

          suggestions.concat(
            rest.strip.split(", ").map(&:strip)
          )
        end
        suggestions
      end
    end
  end
end
