# frozen_string_literal: true

module Uniword
  module Lint
    # Aggregated lint result with severity counts.
    class Result
      SEVERITY_ORDER = %i[error warning info].freeze

      attr_reader :findings

      def initialize
        @findings = []
      end

      # @param finding [Hash]
      # @return [void]
      def add(finding)
        @findings << finding
      end

      # True when at least one :error severity finding exists.
      #
      # @return [Boolean]
      def errors?
        @findings.any? { |f| f[:severity] == :error }
      end

      # Count by severity.
      #
      # @return [Hash{Symbol => Integer}]
      def by_severity
        @findings.group_by { |f| f[:severity] }
          .transform_values(&:count)
      end

      # Count by rule name.
      #
      # @return [Hash{Symbol => Integer}]
      def by_rule
        @findings.group_by { |f| f[:rule] }
          .transform_values(&:count)
      end

      # Total finding count.
      #
      # @return [Integer]
      def count
        @findings.length
      end

      # True when zero findings.
      #
      # @return [Boolean]
      def empty?
        @findings.empty?
      end
    end
  end
end
