# frozen_string_literal: true

module Uniword
  # Find & replace over the text-bearing parts of a DOCX package.
  #
  # Public surface: `Engine` (orchestrator), `Scope` (per-part
  # strategy), `Matcher` (literal or regex), `Result` (counts +
  # per-scope breakdown).
  #
  # Open/closed: adding a new scope = new subclass of `Scope` plus
  # registration. Adding a new matcher type = new subclass of
  # `Matcher`. Engine unchanged in both cases.
  module FindReplace
    autoload :Engine, "#{__dir__}/find_replace/engine"
    autoload :Matcher, "#{__dir__}/find_replace/matcher"
    autoload :StringMatcher, "#{__dir__}/find_replace/string_matcher"
    autoload :RegexMatcher, "#{__dir__}/find_replace/regex_matcher"
    autoload :Scope, "#{__dir__}/find_replace/scope"
    autoload :BodyScope, "#{__dir__}/find_replace/body_scope"
    autoload :HeaderScope, "#{__dir__}/find_replace/header_scope"
    autoload :FooterScope, "#{__dir__}/find_replace/footer_scope"
    autoload :FootnoteScope, "#{__dir__}/find_replace/footnote_scope"
    autoload :EndnoteScope, "#{__dir__}/find_replace/endnote_scope"
    autoload :CommentScope, "#{__dir__}/find_replace/comment_scope"
    autoload :StylesScope, "#{__dir__}/find_replace/styles_scope"
    autoload :ParagraphWalker, "#{__dir__}/find_replace/paragraph_walker"
    autoload :Result, "#{__dir__}/find_replace/result"
  end
end
