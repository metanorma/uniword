# 11: CLI `spellcheck` — spell checking and grammar checking

**Priority:** P2
**Effort:** Medium (~4 hours)
**Files:**
- `lib/uniword/cli.rb` (add `spellcheck` command)
- `lib/uniword/spellcheck/spell_checker.rb` (new)
- `lib/uniword/spellcheck/dictionary.rb` (new)
- `lib/uniword/spellcheck/grammar_checker.rb` (new)
- `config/dictionaries/iso_terms.txt` (new)

## Use Case

ISO editors must verify spelling and grammar in standards documents before
publication. Technical terms, ISO-specific vocabulary, and multilingual content
need specialized dictionaries.

For the Word-alternative vision, spell checking is essential — Word's spell
checker is one of the most-used features.

## Proposed CLI Syntax

```bash
# Spell check a document
uniword spellcheck report.docx

# Show suggestions for each misspelling
uniword spellcheck report.docx --suggest

# Use a specific language dictionary
uniword spellcheck report.docx --lang en_GB

# Add custom dictionary (technical terms)
uniword spellcheck report.docx --dictionary config/dictionaries/iso_terms.txt

# Output as JSON for CI integration
uniword spellcheck report.docx --json

# Interactive mode — fix misspellings one by one
uniword spellcheck report.docx --interactive --output fixed.docx

# Grammar check (separate pass)
uniword spellcheck report.docx --grammar

# List available dictionaries
uniword spellcheck --list-dictionaries
```

## Implementation

### Spell Checker (Hunspell-based)

```ruby
module Uniword
  module Spellcheck
    class SpellChecker
      def initialize(lang: "en_US", dictionaries: [])
        @lang = lang
        @dictionaries = dictionaries
        @hunspell = nil
      end

      def check(document)
        results = []

        document.paragraphs.each_with_index do |paragraph, pi|
          paragraph.runs.each do |run|
            words = extract_words(run.text)
            words.each do |word_info|
              next if correctly_spelled?(word_info[:word])

              results << Misspelling.new(
                word: word_info[:word],
                paragraph_index: pi,
                position: word_info[:position],
                suggestions: suggestions_for(word_info[:word]),
              )
            end
          end
        end

        SpellcheckResult.new(misspellings: results, total_words: count_words(document))
      end

      private

      def correctly_spelled?(word)
        # Check custom dictionaries first
        return true if custom_dictionary?(word)

        # Then Hunspell
        hunspell.check(word)
      end

      def suggestions_for(word)
        hunspell.suggest(word)
      end

      def hunspell
        @hunspell ||= begin
          require "hunspell"  # ruby-hunspell gem
          Hunspell.new(dictionary_path)
        end
      rescue LoadError
        # Fallback to system aspell if hunspell gem not available
        AspellChecker.new(@lang)
      end

      def custom_dictionary?(word)
        @dictionaries.any? { |d| d.include?(word.downcase) }
      end

      def extract_words(text)
        # Split text into words with positions
        # Skip numbers, URLs, XML artifacts
        words = []
        text.scan(/\b([a-zA-Z]+(?:['-][a-zA-Z]+)*)\b/) do |match|
          words << { word: match[0], position: Regexp.last_match.offset(0)[0] }
        end
        words
      end

      def count_words(document)
        document.text.scan(/\b[a-zA-Z]+(?:['-][a-zA-Z]+)*\b/).count
      end
    end
  end
end
```

### Dictionary Management

```ruby
module Uniword::Spellcheck
  class Dictionary
    attr_reader :words

    def initialize(path = nil)
      @words = Set.new
      load(path) if path
    end

    def load(path)
      File.readlines(path, chomp: true).each do |line|
        next if line.start_with?("#") || line.strip.empty?
        @words.add(line.strip.downcase)
      end
    end

    def add(word)
      @words.add(word.downcase)
    end

    def include?(word)
      @words.include?(word.downcase)
    end

    def save(path)
      File.write(path, @words.sort.join("\n") + "\n")
    end

    # Built-in ISO technical terms dictionary
    def self.iso_terms
      new(File.join(Uniword.root, "config", "dictionaries", "iso_terms.txt"))
    end
  end
end
```

### Grammar Checker

```ruby
module Uniword::Spellcheck
  class GrammarChecker
    # Lightweight rule-based grammar checking.
    # For full grammar checking, integrate with LanguageTool via API.

    RULES = [
      # Common issues in technical writing
      { pattern: /\b(shall|should|may|can)\s+not\s+(shall|should|may|can)\b/i,
        message: "Double modal — use 'shall not', 'should not', etc." },
      { pattern: /\bwhich\s+(is|are)\s+being\b/i,
        message: "Passive voice: 'which is being' → consider active voice" },
      { pattern: /\bthere\s+(is|are)\s+\w+\s+that\b/i,
        message: "Wordy: 'there are X that Y' → 'X Y'" },
      { pattern: /\bin order to\b/i,
        message: "Wordy: 'in order to' → 'to'" },
      { pattern: /\bthe\s+the\b/i,
        message: "Doubled word: 'the the'" },
      { pattern: /\b(a|an|the)\s+\1\b/i,
        message: "Doubled word detected" },
      { pattern: /\.\s*\./,
        message: "Double period detected" },
    ].freeze

    def check(document)
      issues = []

      document.paragraphs.each_with_index do |paragraph, pi|
        text = paragraph.text
        next if text.strip.empty?

        RULES.each do |rule|
          text.scan(rule[:pattern]) do
            pos = Regexp.last_match.offset(0)
            issues << GrammarIssue.new(
              rule: rule[:message],
              paragraph_index: pi,
              context: text[[pos[0] - 20, 0].max..[pos[1] + 20, text.length].min],
            )
          end
        end
      end

      GrammarResult.new(issues: issues)
    end
  end
end
```

### Result Types

```ruby
module Uniword::Spellcheck
  Misspelling = Struct.new(:word, :paragraph_index, :position, :suggestions,
                           keyword_init: true)
  GrammarIssue = Struct.new(:rule, :paragraph_index, :context,
                            keyword_init: true)

  class SpellcheckResult
    attr_reader :misspellings, :total_words

    def initialize(misspellings:, total_words:)
      @misspellings = misspellings
      @total_words = total_words
    end

    def correct?
      misspellings.empty?
    end

    def to_json
      {
        total_words: total_words,
        misspelling_count: misspellings.count,
        misspellings: misspellings.map { |m|
          { word: m.word, paragraph: m.paragraph_index, suggestions: m.suggestions }
        }
      }
    end
  end

  class GrammarResult
    attr_reader :issues

    def initialize(issues:)
      @issues = issues
    end

    def correct?
      issues.empty?
    end
  end
end
```

### CLI Integration

```ruby
desc "spellcheck FILE", "Check spelling and grammar"
long_desc <<~DESC
  Check document for spelling errors and common grammar issues.

  Uses Hunspell for spell checking with custom dictionary support.
  Grammar checking uses rule-based patterns.

  Examples:
    $ uniword spellcheck report.docx
    $ uniword spellcheck report.docx --suggest --dictionary iso_terms.txt
    $ uniword spellcheck report.docx --grammar
    $ uniword spellcheck report.docx --interactive --output fixed.docx
DESC
option :lang, desc: "Language (en_US, en_GB, etc.)", default: "en_US"
option :dictionary, desc: "Custom dictionary file", type: :array, default: []
option :suggest, desc: "Show suggestions", type: :boolean, default: false
option :grammar, desc: "Also check grammar", type: :boolean, default: false
option :interactive, desc: "Fix interactively", type: :boolean, default: false
option :output, desc: "Output file for interactive fixes"
option :json, desc: "Output JSON", type: :boolean, default: false
def spellcheck(path)
  doc = DocumentFactory.from_file(path)

  # Load custom dictionaries
  dicts = options[:dictionary].map { |d| Spellcheck::Dictionary.new(d) }
  dicts << Spellcheck::Dictionary.iso_terms  # always load ISO terms

  checker = Spellcheck::SpellChecker.new(lang: options[:lang], dictionaries: dicts)
  result = checker.check(doc)

  if options[:grammar]
    grammar_result = Spellcheck::GrammarChecker.new.check(doc)
    display_grammar(grammar_result)
  end

  if options[:json]
    puts JSON.pretty_generate(result.to_json)
  elsif result.correct?
    say("No spelling errors found (#{result.total_words} words checked)", :green)
  else
    say("Found #{result.misspellings.count} misspelling(s) in #{result.total_words} words:", :yellow)
    result.misspellings.each do |m|
      line = "  Paragraph #{m.paragraph_index + 1}: \"#{m.word}\""
      line += " → #{m.suggestions.first(3).join(', ')}" if options[:suggest] && m.suggestions.any?
      say(line, :yellow)
    end
  end

  exit result.correct? ? 0 : 1
end
```

## Key Design Decisions

1. **Hunspell as primary engine**: industry-standard spell checking, used by
   LibreOffice and Firefox. Ruby binding via `ruby-hunspell` gem.
2. **Custom dictionaries**: ISO-specific terms (normative, informative, etc.)
   pre-loaded, plus user-supplied technical vocabulary.
3. **Grammar is rule-based first**: simple pattern matching for common technical
   writing issues. Full LanguageTool integration is a future enhancement.
4. **CI-friendly exit code**: exits 1 if misspellings found, 0 if clean.
   `--json` for programmatic consumption.
5. **Interactive mode**: single-character TUI for fixing misspellings, same
   pattern as the review command.

## Dependencies

- `ruby-hunspell` gem (Hunspell bindings) — optional, fallback to aspell
- System Hunspell dictionaries (`hunspell-en-us` package on most systems)

## Verification

```bash
bundle exec rspec spec/uniword/spellcheck/
# Test with an ISO document:
uniword spellcheck "spec/fixtures/uniword-private/fixtures/iso/ISO 6709 ed.3 - id.75147 Publication Word (en).docx"
```
