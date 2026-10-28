# frozen_string_literal: true

module Uniword
  # Document redaction and anonymization.
  #
  # Built on FindReplace for content rewriting plus a metadata strip
  # pass for identifying attributes (rsids, author info, revision
  # metadata, hidden text). Compliance use case Word cannot serve.
  module Redact
    autoload :Engine, "#{__dir__}/redact/engine"
    autoload :Pattern, "#{__dir__}/redact/pattern"
    autoload :PatternLibrary, "#{__dir__}/redact/pattern_library"
    autoload :Result, "#{__dir__}/redact/result"
  end
end
