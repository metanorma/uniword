# frozen_string_literal: true

require "thor"
require "json"
require_relative "helpers"

module Uniword
  # Spellcheck subcommands for Uniword CLI.
  #
  # Provides commands for spell and grammar checking documents:
  # - check: run spell and grammar checks on a document
  class SpellcheckCLI < Thor
    include CLIHelpers

    desc "check FILE", "Spell check a document"
    long_desc <<~DESC
      Run spell and grammar checks on a DOCX document.

      Uses hunspell for spell checking and built-in rules for
      grammar issues (double spaces, repeated words, missing
      capitalization).

      Examples:
        $ uniword spellcheck check document.docx
        $ uniword spellcheck check document.docx --language en_GB
        $ uniword spellcheck check document.docx --json
        $ uniword spellcheck check document.docx --verbose
    DESC
    option :language, desc: "Dictionary language", type: :string,
                      default: "en_US"
    option :dictionary, desc: "Custom dictionary file", type: :string
    option :json, desc: "Output JSON report", type: :boolean,
                  default: false
    option :verbose, aliases: "-v", desc: "Show detailed output",
                     type: :boolean, default: false
    def check(path)
      doc = load_document(path)
      say "Spell checking #{path}...", :green

      checker = Spellcheck::SpellChecker.new(
        language: options[:language],
        dictionary: options[:dictionary]
      )
      result = checker.check(doc)

      if options[:json]
        puts result.to_json
      else
        display_text_report(result)
      end

      exit result.clean? ? 0 : 1
    rescue Uniword::DependencyError => e
      say "Error: #{e.message}", :red
      say "Install hunspell: brew install hunspell " \
          "(macOS) or apt install hunspell (Ubuntu)", :yellow
      exit 1
    rescue Uniword::Error => e
      handle_error(e)
    rescue StandardError => e
      handle_error(e)
    end

    private

    # Display human-readable spellcheck results.
    #
    # @param result [Spellcheck::SpellcheckResult] Check results
    # @return [void]
    def display_text_report(result)
      if result.clean?
        say "No issues found.", :green
        return
      end

      say "#{result.issue_count} issue(s) found:", :yellow

      if result.misspellings.any?
        say "\nMisspellings (#{result.misspellings.size}):",
            :cyan
        result.misspellings.each_with_index do |m, idx|
          say "  #{idx + 1}. \"#{m[:word]}\" " \
              "(position #{m[:position]})"
          if options[:verbose] && m[:suggestions].any?
            say "     Suggestions: " \
                "#{m[:suggestions].first(5).join(', ')}"
          end
        end
      end

      if result.grammar_issues.any?
        say "\nGrammar issues " \
            "(#{result.grammar_issues.size}):", :cyan
        result.grammar_issues.each_with_index do |g, idx|
          say "  #{idx + 1}. #{g[:message]} " \
              "(position #{g[:position]})"
          if options[:verbose] && g[:context]
            say "     Context: \"#{g[:context]}\""
          end
        end
      end
    end
  end
end
