# frozen_string_literal: true

module Uniword
  module Spellcheck
    autoload :SpellChecker, "#{__dir__}/spellcheck/spell_checker"
    autoload :HunspellAdapter, "#{__dir__}/spellcheck/hunspell_adapter"
    autoload :GrammarChecker, "#{__dir__}/spellcheck/grammar_checker"
    autoload :SpellcheckResult, "#{__dir__}/spellcheck/spellcheck_result"
  end
end
