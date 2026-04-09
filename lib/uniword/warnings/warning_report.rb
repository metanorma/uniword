# frozen_string_literal: true

require 'json'

module Uniword
  module Warnings
    # Aggregated warning report.
    #
    # Responsibility: Aggregate and report warnings.
    # Single Responsibility: Only manages warning reporting.
    #
    # A warning report includes:
    # - Collection of all warnings
    # - Element occurrence counts
    # - Grouping by severity
    # - Summary statistics
    #
    # @example Create a report
    #   report = WarningReport.new(
    #     warnings: warnings,
    #     element_counts: { 'chart' => 5, 'smartArt' => 2 }
    #   )
    #   puts report.summary
    class WarningReport
      # @return [Array<Warning>] All warnings
      attr_reader :warnings

      # @return [Hash<String, Integer>] Element occurrence counts
      attr_reader :element_counts

      # Initialize a new warning report.
      #
      # @param warnings [Array<Warning>] Warnings to include
      # @param element_counts [Hash<String, Integer>] Element counts
      # @param config [Hash] Configuration
      #
      # @example Create a report
      #   report = WarningReport.new(
      #     warnings: [warning1, warning2],
      #     element_counts: { 'chart' => 3 }
      #   )
      def initialize(warnings:, element_counts:, config: {})
        @warnings = warnings
        @element_counts = element_counts
        @config = config
      end

      # Check if report has any warnings.
      #
      # @return [Boolean] true if warnings exist
      def any?
        @warnings.any?
      end

      # Get error-level warnings.
      #
      # @return [Array<Warning>] Error warnings
      def errors
        @warnings.select(&:error?)
      end

      # Get warning-level warnings.
      #
      # @return [Array<Warning>] Warning-level warnings
      def warnings_only
        @warnings.select(&:warning?)
      end

      # Get info-level warnings.
      #
      # @return [Array<Warning>] Info warnings
      def infos
        @warnings.select(&:info?)
      end

      # Get count of error warnings.
      #
      # @return [Integer] Error count
      def error_count
        errors.count
      end

      # Get count of warning-level warnings.
      #
      # @return [Integer] Warning count
      def warning_count
        warnings_only.count
      end

      # Get count of info warnings.
      #
      # @return [Integer] Info count
      def info_count
        infos.count
      end

      # Get total warning count.
      #
      # @return [Integer] Total count
      def total_count
        @warnings.count
      end

      # Generate summary text.
      #
      # @return [String] Summary text
      def summary
        return 'No warnings' unless any?

        lines = []
        lines << "Found #{total_count} warning(s):"
        lines << "  Errors: #{error_count}"
        lines << "  Warnings: #{warning_count}"
        lines << "  Info: #{info_count}"

        if @element_counts.any?
          lines << ''
          lines << 'Unsupported elements encountered:'

          @element_counts.sort_by { |_, count| -count }.each do |element, count|
            lines << "  #{element}: #{count} occurrence(s)"
          end
        end

        lines.join("\n")
      end

      # Export to JSON string.
      #
      # @return [String] JSON representation
      def to_json(*_args)
        JSON.pretty_generate(to_h)
      end

      # Convert to hash representation.
      #
      # @return [Hash] Hash representation
      def to_h
        {
          total: total_count,
          by_severity: {
            errors: error_count,
            warnings: warning_count,
            infos: info_count
          },
          element_counts: @element_counts,
          warnings: @warnings.map(&:to_h)
        }
      end

      # Convert to string for display.
      #
      # @return [String] String representation
      def to_s
        summary
      end
    end
  end
end
