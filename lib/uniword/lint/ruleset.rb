# frozen_string_literal: true

require "yaml"

module Uniword
  module Lint
    # Loads rules from a YAML ruleset or symbol registry. Each rule
    # has a `type` (which `Rule` subclass to instantiate) and
    # rule-specific options.
    #
    # Example YAML:
    #
    #   rules:
    #     - type: sentence_case_headings
    #       severity: warning
    #     - type: max_paragraph_length
    #       severity: warning
    #       max: 200
    #     - type: banned_words
    #       severity: warning
    #       words: [really, very, basically]
    class Ruleset
      # @param rules [Array<Rule>]
      def initialize(rules = [])
        @rules = rules
      end

      # @return [Array<Rule>]
      attr_reader :rules

      # Load a ruleset from a YAML file.
      #
      # @param path [String]
      # @return [Ruleset]
      def self.load(path)
        data = YAML.safe_load_file(path)
        from_hash(data || {})
      end

      # Build a ruleset from a parsed YAML hash.
      #
      # @param data [Hash] `{"rules" => [{"type" => ..., ...}, ...]}`
      # @return [Ruleset]
      def self.from_hash(data)
        rule_list = (data["rules"] || []).map { |spec| build_rule(spec) }
        new(rule_list)
      end

      # Build one rule from a spec hash by type name.
      #
      # @param spec [Hash] `{"type" => "name", "severity" => ...}`
      # @return [Rule]
      def self.build_rule(spec)
        type = spec["type"].to_sym
        klass = Rule.types[type]
        raise ArgumentError, "unknown rule type: #{spec['type']}" unless klass

        kwargs = spec.transform_keys(&:to_sym)
        kwargs.delete(:type)
        kwargs[:name] = type unless kwargs.key?(:name)
        klass.new(**kwargs)
      end
    end
  end
end
