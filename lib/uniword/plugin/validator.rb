# frozen_string_literal: true

module Uniword
  module Plugin
    # Base class for plugin-provided validation rules. Subclasses
    # implement `#check(document)` (yields findings).
    #
    # Open/closed: adding a new validator = subclassing + calling
    # `Registry.register_validator`.
    class Validator
      # @return [Symbol] validator name (matches the registry key)
      attr_reader :name

      # @return [Symbol] default severity (:error, :warning, :info)
      attr_reader :severity

      # @param name [Symbol]
      # @param severity [Symbol]
      def initialize(name:, severity: :warning)
        @name = name
        @severity = severity
      end

      # Walk the document and yield each finding as a hash.
      #
      # @param document [Wordprocessingml::DocumentRoot]
      # @yieldparam finding [Hash] { message:, path: }
      # @return [void]
      def check(document)
        raise NotImplementedError
      end
    end
  end
end
