# frozen_string_literal: true

module Uniword
  module Lint
    # Container module for builtin rule classes. Loaded eagerly by
    # `Lint` so each class's `register` call fires.
    module BuiltinRules
      autoload :MaxParagraphLength,
               "#{__dir__}/builtin_rules/max_paragraph_length"
      autoload :BannedWords, "#{__dir__}/builtin_rules/banned_words"
      autoload :RequiredStyle, "#{__dir__}/builtin_rules/required_style"
      autoload :RequireBody, "#{__dir__}/builtin_rules/require_body"

      # Touch every autoload to force-load + register each rule.
      ALL = [
        MaxParagraphLength,
        BannedWords,
        RequiredStyle,
        RequireBody,
      ].freeze
    end
  end
end
