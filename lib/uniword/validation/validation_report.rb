# frozen_string_literal: true

require 'json'
require 'yaml'
# ValidationResult autoloaded via lib/uniword/validation.rb

module Uniword
  module Validation
    # Aggregates and reports on validation results.
    #
    # Responsibility: Collect, organize, and export validation results.
    # Single Responsibility: Only manages validation reporting.
    #
    # A validation report includes:
    # - Collection of all validation results
    # - Grouping by status and type
    # - Summary statistics
    # - Export capabilities (JSON, YAML, HTML)
    #
    # @example Create and use a report
    #   report = ValidationReport.new
    #   report.add_result(ValidationResult.success(link1))
    #   report.add_result(ValidationResult.failure(link2, "Not found"))
    #   puts "Valid: #{report.valid?}"
    #   puts "Failures: #{report.failure_count}"
    #   report.export_json('report.json')
    class ValidationReport
      # @return [Array<ValidationResult>] All validation results
      attr_reader :results

      # Initialize a new ValidationReport.
      #
      # @example Create a report
      #   report = ValidationReport.new
      def initialize
        @results = []
      end

      # Add a validation result to the report.
      #
      # @param result [ValidationResult] The result to add
      # @return [ValidationReport] Self for chaining
      #
      # @example Add a result
      #   report.add_result(ValidationResult.success(link))
      def add_result(result)
        raise ArgumentError, 'Expected ValidationResult' unless
          result.is_a?(ValidationResult)

        @results << result
        self
      end

      # Check if all validations passed.
      #
      # @return [Boolean] true if all results are successful
      #
      # @example
      #   report.valid? # => false
      def valid?
        @results.all?(&:valid?)
      end

      # Get all successful results.
      #
      # @return [Array<ValidationResult>] Successful results
      #
      # @example
      #   successes = report.successes
      def successes
        @results.select(&:valid?)
      end

      # Get all failed results.
      #
      # @return [Array<ValidationResult>] Failed results
      #
      # @example
      #   failures = report.failures
      def failures
        @results.select(&:failure?)
      end

      # Get all warning results.
      #
      # @return [Array<ValidationResult>] Warning results
      #
      # @example
      #   warnings = report.warnings
      def warnings
        @results.select(&:warning?)
      end

      # Get all unknown/skipped results.
      #
      # @return [Array<ValidationResult>] Unknown results
      #
      # @example
      #   unknowns = report.unknowns
      def unknowns
        @results.select(&:unknown?)
      end

      # Get count of successful validations.
      #
      # @return [Integer] Success count
      #
      # @example
      #   count = report.success_count
      def success_count
        successes.count
      end

      # Get count of failed validations.
      #
      # @return [Integer] Failure count
      #
      # @example
      #   count = report.failure_count
      def failure_count
        failures.count
      end

      # Get count of warnings.
      #
      # @return [Integer] Warning count
      #
      # @example
      #   count = report.warning_count
      def warning_count
        warnings.count
      end

      # Get count of unknown/skipped validations.
      #
      # @return [Integer] Unknown count
      #
      # @example
      #   count = report.unknown_count
      def unknown_count
        unknowns.count
      end

      # Get total count of results.
      #
      # @return [Integer] Total count
      #
      # @example
      #   total = report.total_count
      def total_count
        @results.count
      end

      # Group results by link type.
      #
      # @return [Hash{Symbol => Array<ValidationResult>}] Grouped results
      #
      # @example
      #   grouped = report.group_by_type
      #   # => { external: [...], internal: [...], ... }
      def group_by_type
        @results.group_by do |result|
          classify_link_type(result.link)
        end
      end

      # Get summary statistics.
      #
      # @return [Hash] Summary data
      #
      # @example
      #   summary = report.summary
      #   # => { total: 10, successes: 8, failures: 2, ... }
      def summary
        {
          total: total_count,
          successes: success_count,
          failures: failure_count,
          warnings: warning_count,
          unknowns: unknown_count,
          valid: valid?
        }
      end

      # Export report to JSON file.
      #
      # @param file_path [String] Path to output file
      # @return [void]
      #
      # @example
      #   report.export_json('link_report.json')
      def export_json(file_path)
        File.write(file_path, to_json)
      end

      # Export report to YAML file.
      #
      # @param file_path [String] Path to output file
      # @return [void]
      #
      # @example
      #   report.export_yaml('link_report.yml')
      def export_yaml(file_path)
        File.write(file_path, to_yaml)
      end

      # Export report to HTML file.
      #
      # @param file_path [String] Path to output file
      # @return [void]
      #
      # @example
      #   report.export_html('link_report.html')
      def export_html(file_path)
        File.write(file_path, to_html)
      end

      # Convert to JSON string.
      #
      # @return [String] JSON representation
      #
      # @example
      #   json = report.to_json
      def to_json(*)
        JSON.pretty_generate(to_h, *)
      end

      # Convert to YAML string.
      #
      # @return [String] YAML representation
      #
      # @example
      #   yaml = report.to_yaml
      def to_yaml
        YAML.dump(to_h)
      end

      # Convert to HTML string.
      #
      # @return [String] HTML representation
      #
      # @example
      #   html = report.to_html
      def to_html
        <<~HTML
          <!DOCTYPE html>
          <html>
          <head>
            <title>Link Validation Report</title>
            <style>
              body { font-family: Arial, sans-serif; margin: 20px; }
              h1 { color: #333; }
              .summary { background: #f5f5f5; padding: 15px; border-radius: 5px; margin-bottom: 20px; }
              .summary-item { display: inline-block; margin-right: 20px; }
              table { border-collapse: collapse; width: 100%; margin-top: 20px; }
              th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
              th { background-color: #4CAF50; color: white; }
              .success { color: green; }
              .failure { color: red; }
              .warning { color: orange; }
              .unknown { color: gray; }
            </style>
          </head>
          <body>
            <h1>Link Validation Report</h1>
            #{summary_html}
            #{results_table_html}
          </body>
          </html>
        HTML
      end

      # Convert to hash representation.
      #
      # @return [Hash] Hash representation
      #
      # @example
      #   hash = report.to_h
      def to_h
        {
          summary: summary,
          results: @results.map(&:to_h),
          by_type: group_by_type.transform_values do |results|
            results.map(&:to_h)
          end
        }
      end

      # Convert to string for display.
      #
      # @return [String] String representation
      #
      # @example
      #   puts report.to_s
      def to_s
        lines = [
          'Link Validation Report',
          '=' * 50,
          "Total: #{total_count}",
          "Successes: #{success_count}",
          "Failures: #{failure_count}",
          "Warnings: #{warning_count}",
          "Unknowns: #{unknown_count}",
          "Valid: #{valid?}",
          ''
        ]

        if failures.any?
          lines << 'Failed Links:'
          failures.each do |result|
            lines << "  - #{result}"
          end
        end

        if warnings.any?
          lines << ''
          lines << 'Warnings:'
          warnings.each do |result|
            lines << "  - #{result}"
          end
        end

        lines.join("\n")
      end

      private

      # Classify link type based on link object.
      #
      # @param link [Object] The link object
      # @return [Symbol] Link type
      def classify_link_type(link)
        if link.respond_to?(:url) && link.url
          :external
        elsif link.respond_to?(:anchor) && link.anchor
          :internal
        elsif link.respond_to?(:id)
          :footnote
        elsif link.is_a?(String) && File.exist?(link)
          :file
        else
          :unknown
        end
      end

      # Generate HTML summary section.
      #
      # @return [String] HTML for summary
      def summary_html
        status_class = valid? ? 'success' : 'failure'
        <<~HTML
          <div class="summary">
            <div class="summary-item"><strong>Total Links:</strong> #{total_count}</div>
            <div class="summary-item"><strong>Successes:</strong> <span class="success">#{success_count}</span></div>
            <div class="summary-item"><strong>Failures:</strong> <span class="failure">#{failure_count}</span></div>
            <div class="summary-item"><strong>Warnings:</strong> <span class="warning">#{warning_count}</span></div>
            <div class="summary-item"><strong>Status:</strong> <span class="#{status_class}">#{valid? ? 'VALID' : 'INVALID'}</span></div>
          </div>
        HTML
      end

      # Generate HTML results table.
      #
      # @return [String] HTML for results table
      def results_table_html
        return '<p>No results to display.</p>' if @results.empty?

        rows = @results.map do |result|
          status_class = result.status.to_s
          <<~HTML
            <tr>
              <td class="#{status_class}">#{result.status.to_s.upcase}</td>
              <td>#{escape_html(result.link_identifier)}</td>
              <td>#{escape_html(result.message || '-')}</td>
            </tr>
          HTML
        end

        <<~HTML
          <table>
            <thead>
              <tr>
                <th>Status</th>
                <th>Link</th>
                <th>Message</th>
              </tr>
            </thead>
            <tbody>
              #{rows.join}
            </tbody>
          </table>
        HTML
      end

      # Escape HTML special characters.
      #
      # @param text [String] Text to escape
      # @return [String] Escaped text
      def escape_html(text)
        text.to_s
            .gsub('&', '&amp;')
            .gsub('<', '&lt;')
            .gsub('>', '&gt;')
            .gsub('"', '&quot;')
            .gsub("'", '&#39;')
      end
    end
  end
end
