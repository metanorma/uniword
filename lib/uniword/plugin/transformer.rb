# frozen_string_literal: true

module Uniword
  module Plugin
    # Base class for plugin-provided document transformers.
    # Subclasses implement `#transform(document)` which mutates the
    # document in place.
    #
    # Pipelines call transformers at defined stages; see
    # `Plugin.transform_for_stage`.
    class Transformer
      STAGES = %i[after_load before_save after_reconcile].freeze

      # @return [Symbol] transformer name
      attr_reader :name

      # @return [Array<Symbol>] stages when this transformer runs
      attr_reader :stages

      # @param name [Symbol]
      # @param stages [Array<Symbol>, Symbol] one or more of
      #   STAGES; defaults to `:before_save`
      def initialize(name:, stages: :before_save)
        @name = name
        @stages = Array(stages)
        unknown = @stages - STAGES
        return if unknown.empty?

        raise ArgumentError,
              "unknown stages: #{unknown.inspect}; valid: #{STAGES.inspect}"
      end

      # True when this transformer runs at the given stage.
      #
      # @param stage [Symbol]
      # @return [Boolean]
      def applies_to?(stage)
        @stages.include?(stage)
      end

      # Mutate the document. Subclasses override.
      #
      # @param document [Wordprocessingml::DocumentRoot]
      # @return [void]
      def transform(document)
        raise NotImplementedError
      end
    end
  end
end
