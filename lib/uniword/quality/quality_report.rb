# frozen_string_literal: true

require 'json'
require 'yaml'

module Uniword
  module Quality
    # Manages and reports document quality violations.
    #
    # Responsibility: Collect, organize, and export quality check results.
    # Single Responsibility - only handles report generation and export.
    #
    # @example Generate and use report
    #   report = QualityReport.new
    #   report.add_violation(violation)
    #   puts "Valid: #{report.valid?}"
    #   puts "Errors: #{report.error_count}"
    #   report.export_html('report.html')
    class QualityReport
      attr_reader :violations, :checked_at

      # Initialize quality report
      def initialize
        @violations = []
        @checked_at = Time.now
      end

      # Add a violation to the report
      #
      # @param violation [QualityViolation] The violation to add
      # @return [void]
      def add_violation(violation)
        @violations << violation
      end

      # Add multiple violations to the report
      #
      # @param violations [Array<QualityViolation>] Violations to add
      # @return [void]
      def add_violations(violations)
        @violations.concat(violations)
      end

      # Check if document is valid (no errors)
      #
      # @return [Boolean] true if no error-level violations
      def valid?
        error_count.zero?
      end

      # Get count of error-level violations
      #
      # @return [Integer] Number of errors
      def error_count
        violations.count(&:error?)
      end

      # Get count of warning-level violations
      #
      # @return [Integer] Number of warnings
      def warning_count
        violations.count(&:warning?)
      end

      # Get count of info-level violations
      #
      # @return [Integer] Number of info items
      def info_count
        violations.count(&:info?)
      end

      # Get total violation count
      #
      # @return [Integer] Total number of violations
      def total_count
        violations.count
      end

      # Get violations grouped by severity
      #
      # @return [Hash{Symbol => Array<QualityViolation>}] Violations by severity
      def by_severity
        {
          error: violations.select(&:error?),
          warning: violations.select(&:warning?),
          info: violations.select(&:info?)
        }
      end

      # Get violations grouped by rule
      #
      # @return [Hash{String => Array<QualityViolation>}] Violations by rule
      def by_rule
        violations.group_by(&:rule)
      end

      # Export report as JSON
      #
      # @param file_path [String] Path to save JSON file (optional)
      # @return [String] JSON string
      def to_json(file_path = nil)
        json_data = {
          checked_at: checked_at.iso8601,
          summary: {
            total: total_count,
            errors: error_count,
            warnings: warning_count,
            info: info_count,
            valid: valid?
          },
          violations: violations.map(&:to_h)
        }

        json_string = JSON.pretty_generate(json_data)

        if file_path
          File.write(file_path, json_string)
        end

        json_string
      end

      # Export report as YAML
      #
      # @param file_path [String] Path to save YAML file (optional)
      # @return [String] YAML string
      def to_yaml(file_path = nil)
        yaml_data = {
          'checked_at' => checked_at.iso8601,
          'summary' => {
            'total' => total_count,
            'errors' => error_count,
            'warnings' => warning_count,
            'info' => info_count,
            'valid' => valid?
          },
          'violations' => violations.map(&:to_h)
        }

        yaml_string = YAML.dump(yaml_data)

        if file_path
          File.write(file_path, yaml_string)
        end

        yaml_string
      end

      # Export report as HTML
      #
      # @param file_path [String] Path to save HTML file
      # @return [String] HTML string
      def export_html(file_path)
        html = generate_html
        File.write(file_path, html)
        html
      end

      # Get formatted summary text
      #
      # @return [String] Human-readable summary
      def summary
        [
          "Document Quality Report",
          "=" * 50,
          "Checked at: #{checked_at}",
          "Status: #{valid? ? 'VALID' : 'INVALID'}",
          "",
          "Summary:",
          "  Total violations: #{total_count}",
          "  Errors: #{error_count}",
          "  Warnings: #{warning_count}",
          "  Info: #{info_count}"
        ].join("\n")
      end

      private

      # Generate HTML report
      #
      # @return [String] HTML content
      def generate_html
        <<~HTML
          <!DOCTYPE html>
          <html>
          <head>
            <meta charset="UTF-8">
            <title>Document Quality Report</title>
            <style>
              body {
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                max-width: 1200px;
                margin: 40px auto;
                padding: 20px;
                background-color: #f5f5f5;
              }
              h1 { color: #333; }
              .summary {
                background: white;
                padding: 20px;
                border-radius: 8px;
                margin-bottom: 20px;
                box-shadow: 0 2px 4px rgba(0,0,0,0.1);
              }
              .status { font-size: 1.2em; font-weight: bold; }
              .status.valid { color: #28a745; }
              .status.invalid { color: #dc3545; }
              .stats {
                display: grid;
                grid-template-columns: repeat(4, 1fr);
                gap: 15px;
                margin-top: 15px;
              }
              .stat {
                background: #f8f9fa;
                padding: 15px;
                border-radius: 4px;
                text-align: center;
              }
              .stat-value { font-size: 2em; font-weight: bold; }
              .stat-label { color: #6c757d; margin-top: 5px; }
              .violations {
                background: white;
                padding: 20px;
                border-radius: 8px;
                box-shadow: 0 2px 4px rgba(0,0,0,0.1);
              }
              .violation {
                padding: 15px;
                margin-bottom: 10px;
                border-left: 4px solid;
                background: #f8f9fa;
                border-radius: 4px;
              }
              .violation.error { border-left-color: #dc3545; }
              .violation.warning { border-left-color: #ffc107; }
              .violation.info { border-left-color: #17a2b8; }
              .violation-header {
                display: flex;
                justify-content: space-between;
                margin-bottom: 8px;
              }
              .severity {
                padding: 2px 8px;
                border-radius: 3px;
                font-size: 0.85em;
                font-weight: bold;
                text-transform: uppercase;
              }
              .severity.error { background: #dc3545; color: white; }
              .severity.warning { background: #ffc107; color: #000; }
              .severity.info { background: #17a2b8; color: white; }
              .rule { color: #6c757d; font-size: 0.9em; }
              .message { margin: 8px 0; }
              .location { color: #6c757d; font-size: 0.9em; font-family: monospace; }
            </style>
          </head>
          <body>
            <h1>Document Quality Report</h1>

            <div class="summary">
              <div>Checked at: #{checked_at}</div>
              <div class="status #{valid? ? 'valid' : 'invalid'}">
                Status: #{valid? ? 'VALID ✓' : 'INVALID ✗'}
              </div>

              <div class="stats">
                <div class="stat">
                  <div class="stat-value">#{total_count}</div>
                  <div class="stat-label">Total</div>
                </div>
                <div class="stat">
                  <div class="stat-value" style="color: #dc3545;">#{error_count}</div>
                  <div class="stat-label">Errors</div>
                </div>
                <div class="stat">
                  <div class="stat-value" style="color: #ffc107;">#{warning_count}</div>
                  <div class="stat-label">Warnings</div>
                </div>
                <div class="stat">
                  <div class="stat-value" style="color: #17a2b8;">#{info_count}</div>
                  <div class="stat-label">Info</div>
                </div>
              </div>
            </div>

            #{generate_violations_html}
          </body>
          </html>
        HTML
      end

      # Generate HTML for violations section
      #
      # @return [String] HTML content for violations
      def generate_violations_html
        return "" if violations.empty?

        violations_html = violations.map do |v|
          <<~HTML
            <div class="violation #{v.severity}">
              <div class="violation-header">
                <span class="severity #{v.severity}">#{v.severity}</span>
                <span class="rule">#{v.rule}</span>
              </div>
              <div class="message">#{v.message}</div>
              <div class="location">Location: #{v.location}</div>
            </div>
          HTML
        end.join("\n")

        <<~HTML
          <div class="violations">
            <h2>Violations (#{violations.count})</h2>
            #{violations_html}
          </div>
        HTML
      end
    end
  end
end