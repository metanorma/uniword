# frozen_string_literal: true

require "json"

module Uniword
  module Accessibility
    # Accessibility Report - aggregated accessibility check results
    #
    # Responsibility: Aggregate violations and generate reports
    # Single Responsibility: Report generation and export only
    #
    # @example Using the report
    #   report = AccessibilityReport.new(
    #     profile_name: "WCAG 2.1",
    #     profile_level: "Level AA"
    #   )
    #   report.add_violation(violation1)
    #   report.add_violation(violation2)
    #   puts report.summary
    #   report.export_html('report.html')
    class AccessibilityReport
      attr_reader :profile_name, :profile_level, :violations

      # Initialize a new accessibility report
      #
      # @param profile_name [String] Name of the profile used
      # @param profile_level [String] Level of the profile (A, AA, AAA)
      def initialize(profile_name:, profile_level:)
        @profile_name = profile_name
        @profile_level = profile_level
        @violations = []
      end

      # Add a violation to the report
      #
      # @param violation [AccessibilityViolation] Violation to add
      # @return [void]
      def add_violation(violation)
        @violations << violation
      end

      # Check if document is compliant (no errors)
      #
      # @return [Boolean] True if no errors exist
      def compliant?
        errors.empty?
      end

      # Get all error-level violations
      #
      # @return [Array<AccessibilityViolation>] Error violations
      def errors
        @violations.select(&:error?)
      end

      # Get all warning-level violations
      #
      # @return [Array<AccessibilityViolation>] Warning violations
      def warnings
        @violations.select(&:warning?)
      end

      # Get all info-level violations
      #
      # @return [Array<AccessibilityViolation>] Info violations
      def infos
        @violations.select(&:info?)
      end

      # Generate a text summary of the report
      #
      # @return [String] Formatted summary text
      def summary
        return "✅ Document is accessible (#{@profile_name} #{@profile_level})" if compliant?

        lines = []
        lines << "❌ Document has accessibility issues (#{@profile_name} #{@profile_level}):"
        lines << "  Errors: #{errors.count} (must fix)"
        lines << "  Warnings: #{warnings.count} (should fix)"
        lines << "  Info: #{infos.count} (recommended)"
        lines << ""

        # Group by rule
        by_rule = @violations.group_by(&:rule_id)
        by_rule.each do |rule_id, rule_violations|
          lines << "#{rule_id} (#{rule_violations.count} issues):"
          rule_violations.first(3).each do |v|
            lines << "  - #{v.message}"
          end
          lines << "  ... and #{rule_violations.count - 3} more" if rule_violations.count > 3
        end

        lines.join("\n")
      end

      # Export report to JSON format
      #
      # @return [String] JSON representation of report
      def to_json(*_args)
        JSON.pretty_generate(
          profile: {
            name: @profile_name,
            level: @profile_level
          },
          compliant: compliant?,
          summary: {
            total: @violations.count,
            errors: errors.count,
            warnings: warnings.count,
            infos: infos.count
          },
          violations: @violations.map(&:to_h)
        )
      end

      # Export report to HTML file
      #
      # @param file_path [String] Path to save HTML report
      # @return [void]
      def export_html(file_path)
        html = generate_html
        File.write(file_path, html)
      end

      private

      # Generate HTML report content
      #
      # @return [String] Complete HTML document
      def generate_html
        <<~HTML
          <!DOCTYPE html>
          <html>
          <head>
            <title>Accessibility Report - #{@profile_name} #{@profile_level}</title>
            <style>
              body { font-family: Arial, sans-serif; margin: 20px; line-height: 1.6; }
              h1, h2, h3 { color: #333; }
              .compliant { color: #4caf50; font-weight: bold; }
              .non-compliant { color: #f44336; font-weight: bold; }
              .summary { background: #f5f5f5; padding: 15px; border-radius: 5px; margin: 20px 0; }
              .error { background-color: #ffebee; padding: 15px; margin: 10px 0; border-left: 4px solid #f44336; }
              .warning { background-color: #fff3e0; padding: 15px; margin: 10px 0; border-left: 4px solid #ff9800; }
              .info { background-color: #e3f2fd; padding: 15px; margin: 10px 0; border-left: 4px solid #2196f3; }
              .violation-header { font-weight: bold; margin-bottom: 10px; }
              .wcag-ref { color: #666; font-size: 0.9em; }
              ul { margin: 10px 0; }
              li { margin: 5px 0; }
              .suggestion { font-style: italic; color: #555; margin-top: 5px; }
            </style>
          </head>
          <body>
            <h1>Accessibility Report</h1>
            <p><strong>Profile:</strong> #{@profile_name} #{@profile_level}</p>
            <p class="#{compliant? ? "compliant" : "non-compliant"}">
              Status: #{compliant? ? "✅ Compliant" : "❌ Not Compliant"}
            </p>

            <div class="summary">
              <h2>Summary</h2>
              <ul>
                <li>Total Issues: #{@violations.count}</li>
                <li>Errors (must fix): #{errors.count}</li>
                <li>Warnings (should fix): #{warnings.count}</li>
                <li>Info (recommended): #{infos.count}</li>
              </ul>
            </div>

            <h2>Violations</h2>
            #{violations_html}
          </body>
          </html>
        HTML
      end

      # Generate HTML for violations section
      #
      # @return [String] HTML content for violations
      def violations_html
        return "<p>No violations found.</p>" if @violations.empty?

        @violations.group_by(&:rule_id).map do |rule_id, rule_violations|
          severity_class = rule_violations.first.severity
          <<~HTML
            <div class="#{severity_class}">
              <div class="violation-header">
                #{format_rule_name(rule_id)} (#{rule_violations.count} issues)
              </div>
              <div class="wcag-ref">WCAG: #{rule_violations.first.wcag_criterion}</div>
              <ul>
                #{rule_violations.map do |v|
                  "<li>#{v.message}<div class=\"suggestion\">💡 #{v.suggestion}</div></li>"
                end.join("\n")}
              </ul>
            </div>
          HTML
        end.join("\n")
      end

      # Format rule ID for display
      #
      # @param rule_id [Symbol] Rule identifier
      # @return [String] Formatted rule name
      def format_rule_name(rule_id)
        rule_id.to_s
               .split("_")
               .map(&:capitalize)
               .join(" ")
      end
    end
  end
end
