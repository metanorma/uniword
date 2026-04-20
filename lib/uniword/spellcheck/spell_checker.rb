# frozen_string_literal: true

module Uniword
  module Spellcheck
    # Main orchestrator for spell and grammar checking.
    #
    # Responsibility: Extract text from a document, delegate to
    # HunspellAdapter for spell checking and GrammarChecker for
    # grammar issues, then aggregate results into a SpellcheckResult.
    #
    # @example Check a document
    #   checker = SpellChecker.new(language: "en_US")
    #   doc = Uniword::DocumentFactory.from_file("report.docx")
    #   result = checker.check(doc)
    #   puts result.to_json
    class SpellChecker
      attr_reader :spell_adapter, :grammar_checker, :language

      # Initialize the spell checker.
      #
      # @param language [String] Dictionary language (default: "en_US")
      # @param dictionary [String, nil] Custom dictionary file path
      #   (reserved for future use)
      # @param spell_adapter [HunspellAdapter, nil] Override adapter
      #   (useful for testing)
      def initialize(language: "en_US", dictionary: nil,
                     spell_adapter: nil)
        @language = language
        @dictionary = dictionary
        @spell_adapter = spell_adapter ||
                         HunspellAdapter.new(language: language)
        @grammar_checker = GrammarChecker.new
      end

      # Run spell and grammar checks on a document.
      #
      # @param document [DocumentRoot] The document to check
      # @return [SpellcheckResult] Combined check results
      def check(document)
        text = extract_text(document)
        result = SpellcheckResult.new

        check_spelling(text, result)
        check_grammar(text, result)

        result
      end

      private

      # Extract all text content from a document.
      #
      # Collects text from paragraphs and table cells, joining with
      # newlines to preserve structure.
      #
      # @param document [DocumentRoot] The document
      # @return [String] Extracted text
      def extract_text(document)
        parts = []

        paragraphs = document.respond_to?(:paragraphs) ?
                     document.paragraphs : []
        paragraphs.each do |para|
          parts << para.text if para.respond_to?(:text)
        end

        tables = document.respond_to?(:tables) ?
                 document.tables : []
        tables.each do |table|
          extract_table_text(table, parts)
        end

        parts.join("\n")
      end

      # Extract text from all cells in a table.
      #
      # @param table [Table] The table
      # @param parts [Array<String>] Accumulator for text parts
      # @return [void]
      def extract_table_text(table, parts)
        return unless table.respond_to?(:rows)

        table.rows.each do |row|
          next unless row.respond_to?(:cells)

          row.cells.each do |cell|
            parts << cell.text if cell.respond_to?(:text)
          end
        end
      end

      # Check individual words against the spell adapter.
      #
      # Extracts words, checks each one, and records misspellings
      # with their position in the full text and any suggestions.
      #
      # @param text [String] Full document text
      # @param result [SpellcheckResult] Result accumulator
      # @return [void]
      def check_spelling(text, result)
        return if text.empty?

        word_positions(text).each do |word, pos|
          next if spell_adapter.check(word)

          suggestions = spell_adapter.suggest(word)
          result.add_misspelling(
            word: word,
            position: pos,
            suggestions: suggestions
          )
        end
      end

      # Run grammar rules against the full text.
      #
      # @param text [String] Full document text
      # @param result [SpellcheckResult] Result accumulator
      # @return [void]
      def check_grammar(text, result)
        return if text.empty?

        issues = grammar_checker.check(text)
        issues.each do |issue|
          result.add_grammar_issue(**issue)
        end
      end

      # Extract words and their positions from text.
      #
      # Skips pure numbers, standalone punctuation, and words
      # shorter than 2 characters.
      #
      # @param text [String] The text to scan
      # @return [Array<Array(String, Integer)>] Word and position pairs
      def word_positions(text)
        words = []
        text.scan(/\b[\p{L}'][\p{L}'-]*\b/) do
          match = Regexp.last_match
          word = match[0]
          pos = match.begin(0)

          # Skip very short "words" and pure numbers
          next if word.length < 2
          next if word.match?(/\A\d+\z/)

          words << [word, pos]
        end
        words
      end
    end
  end
end
