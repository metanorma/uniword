# frozen_string_literal: true

require_relative '../processing_stage'
require_relative '../../quality/document_checker'

module Uniword
  module Batch
    # Processing stage that runs quality checks on documents.
    #
    # Responsibility: Run document quality checker with configured rules.
    # Single Responsibility - only handles quality checking.
    #
    # @example Use in pipeline
    #   stage = QualityCheckStage.new(
    #     rules_file: 'config/quality_rules.yml',
    #     fail_on_errors: false
    #   )
    #   document = stage.process(document, context)
    class QualityCheckStage < ProcessingStage
      # Initialize quality check stage
      #
      # @param options [Hash] Stage options
      # @option options [String] :rules_file Path to quality rules configuration
      # @option options [Boolean] :fail_on_errors Raise error if quality errors found
      # @option options [Boolean] :fail_on_warnings Raise error if warnings found
      # @option options [Boolean] :generate_report Generate quality report file
      def initialize(options = {})
        super
        @rules_file = options[:rules_file]
        @fail_on_errors = options.fetch(:fail_on_errors, false)
        @fail_on_warnings = options.fetch(:fail_on_warnings, false)
        @generate_report = options.fetch(:generate_report, true)

        # Initialize quality checker
        @checker = initialize_checker
      end

      # Process document to run quality checks
      #
      # @param document [Document] Document to process
      # @param context [Hash] Processing context
      # @return [Document] Processed document
      # @raise [QualityCheckError] if quality checks fail and fail_on_errors is true
      def process(document, context = {})
        log "Running quality checks on #{context[:filename]}"

        # Run quality checker
        report = @checker.check(document)

        # Log results
        log_report_summary(report)

        # Generate report file if requested
        generate_report_file(report, context) if @generate_report && context[:output_path]

        # Check if we should fail
        check_failure_conditions(report, context[:filename])

        document
      end

      # Get stage description
      #
      # @return [String] Description
      def description
        'Run quality checks'
      end

      private

      # Initialize quality checker
      #
      # @return [Quality::DocumentChecker] Checker instance
      def initialize_checker
        if @rules_file
          Quality::DocumentChecker.new(rules_file: @rules_file)
        else
          Quality::DocumentChecker.new
        end
      rescue Quality::QualityCheckError => e
        log "Failed to initialize quality checker: #{e.message}", level: :error
        # Return checker with default config
        Quality::DocumentChecker.new
      end

      # Log report summary
      #
      # @param report [Quality::QualityReport] Quality report
      def log_report_summary(report)
        if report.valid?
          log 'Quality check passed - no violations found'
        else
          error_count = report.errors.size
          warning_count = report.warnings.size
          info_count = report.infos.size

          log 'Quality check found violations:', level: :warn
          log "  Errors: #{error_count}", level: :warn if error_count.positive?
          log "  Warnings: #{warning_count}", level: :warn if warning_count.positive?
          log "  Info: #{info_count}" if info_count.positive?

          # Log first few violations
          report.violations.first(5).each do |violation|
            level = violation.error? ? :error : :warn
            log "  [#{violation.severity.upcase}] #{violation.rule}: #{violation.message}",
                level: level
          end

          if report.violations.size > 5
            log "  ... and #{report.violations.size - 5} more violation(s)"
          end
        end
      end

      # Generate quality report file
      #
      # @param report [Quality::QualityReport] Quality report
      # @param context [Hash] Processing context
      def generate_report_file(report, context)
        output_dir = File.dirname(context[:output_path])
        filename = File.basename(context[:input_path], '.*')
        report_path = File.join(output_dir, "#{filename}_quality_report.json")

        begin
          File.write(report_path, report.to_json)
          log "Quality report saved to #{report_path}"
        rescue StandardError => e
          log "Failed to save quality report: #{e.message}", level: :warn
        end
      end

      # Check failure conditions and raise if needed
      #
      # @param report [Quality::QualityReport] Quality report
      # @param filename [String] Filename for error message
      # @raise [QualityCheckError] if conditions met
      def check_failure_conditions(report, filename)
        if @fail_on_errors && report.has_errors?
          raise Quality::QualityCheckError,
                "Quality check failed for #{filename}: " \
                "#{report.errors.size} error(s) found"
        end

        return unless @fail_on_warnings && report.has_warnings?

        raise Quality::QualityCheckError,
              "Quality check failed for #{filename}: " \
              "#{report.warnings.size} warning(s) found"
      end
    end
  end
end
