# frozen_string_literal: true

module Uniword
  module Lint
    # Abstract base class for a single lint rule. Subclasses implement
    # `#check` (yields findings) and declare `name`, `severity`.
    #
    # Open/closed: new rule type = new subclass + (optionally) a
    # YAML schema extension. Engine unchanged.
    class Rule
      # Registered rule subclasses by type name. Constant on `Rule`
      # itself (not subclasses) so `register` calls always reach the
      # same hash. `Hash.new` (rather than `{}`) avoids the
      # Style/MutableConstant autocorrect that would `.freeze` it and
      # break `register`.
      TYPES = Hash.new

      attr_reader :name, :severity, :options

      # @param name [Symbol] rule identifier
      # @param severity [Symbol] :error, :warning, or :info
      # @param options [Hash] rule-specific options
      def initialize(name:, severity: :warning, **options)
        @name = name
        @severity = severity
        @options = options
      end

      # Walk the document and yield each finding.
      #
      # @param document [Wordprocessingml::DocumentRoot]
      # @yieldparam finding [Hash] { message:, path:, position: }
      # @return [void]
      def check(document)
        raise NotImplementedError
      end

      # Build a finding hash.
      #
      # @param message [String]
      # @param path [String, nil] document path (paragraph index,
      #   style id, etc.)
      # @return [Hash]
      def finding(message:, path: nil)
        { rule: name, severity: severity, message: message, path: path }
      end

      class << self
        # Register a subclass under a type name for YAML ruleset
        # lookup. Always writes to `Rule::TYPES` regardless of the
        # calling subclass.
        #
        # @param name [Symbol]
        # @param klass [Class<Rule>]
        # @return [void]
        def register(name, klass)
          Rule::TYPES[name] = klass
        end

        # Lookup a registered rule subclass by type name.
        #
        # @param name [Symbol]
        # @return [Class<Rule>, nil]
        def type(name)
          Rule::TYPES[name]
        end

        # All registered rule types.
        #
        # @return [Hash{Symbol => Class<Rule>}]
        def types
          Rule::TYPES
        end
      end
    end
  end
end
