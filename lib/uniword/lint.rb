# frozen_string_literal: true

module Uniword
  # Document lint: enforce content + structure rules beyond OPC
  # validity. Backed by a YAML ruleset; rules are open for extension
  # via `Lint::Rule.register`.
  module Lint
    autoload :Engine, "#{__dir__}/lint/engine"
    autoload :Ruleset, "#{__dir__}/lint/ruleset"
    autoload :Rule, "#{__dir__}/lint/rule"
    autoload :Result, "#{__dir__}/lint/result"
    autoload :BuiltinRules, "#{__dir__}/lint/builtin_rules"

    # Force-load the builtins so their `register` calls run.
    BuiltinRules.to_s
  end
end
