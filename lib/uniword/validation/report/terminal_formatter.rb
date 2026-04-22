# frozen_string_literal: true

require "rainbow"
require_relative "verification_report"

module Uniword
  module Validation
    module Report
      # Formats a VerificationReport as rich terminal output using Rainbow.
      class TerminalFormatter
        LAYER_WIDTH = 48

        # Format a report for terminal display.
        #
        # @param report [VerificationReport] The report to format
        # @param verbose [Boolean] Show detailed issue listing
        # @return [String] Formatted terminal output
        def format(report, verbose: false)
          lines = []
          lines << ""
          lines << Rainbow("  \xF0\x9F\x94\x8D  Verifying: #{report.file_path}").bright
          lines << ""

          report.layers.each do |layer|
            lines << format_layer(layer)
            if verbose || layer.fail?
              layer.issues.each { |issue| lines << format_issue(issue) }
            elsif layer.warnings.any?
              layer.warnings.each { |issue| lines << format_issue(issue) }
            end
          end

          lines << ""
          lines << Rainbow("\xE2\x94\x80" * 52).color("#555555")
          lines << format_summary(report)
          lines << ""
          lines.join("\n")
        end

        private

        def format_layer(layer)
          status_icon = if layer.pass?
                          Rainbow(" \xE2\x9C\x85 ").green
                        else
                          Rainbow(" \xE2\x9D\x8C ").red
                        end

          name_display = Rainbow(layer.name).bright
          fill = "\xE2\x94\x81" * [LAYER_WIDTH - layer.name.length - 2, 3].max
          timing = Rainbow("(#{layer.duration_ms}ms)").color("#888888")

          "#{name_display} #{Rainbow(fill).color("#444444")} #{status_icon}#{timing}"
        end

        def format_issue(issue)
          icon = severity_icon(issue.severity)
          code = Rainbow(issue.code).bright

          parts = ["#{icon}  #{code}"]
          parts << Rainbow("  #{issue.part}#{line_suffix(issue)}").color("#888888") if issue.part
          parts << ""
          parts << "   #{issue.message}"

          parts << "   #{Rainbow("\xF0\x9F\x92\xA1").bright} #{Rainbow(issue.suggestion).italic}" if issue.suggestion

          parts.join("\n")
        end

        def format_summary(report)
          layers_count = report.layers.count
          errors = report.all_errors.count
          warnings = report.all_warnings.count

          parts = [Rainbow("  \xF0\x9F\x93\x8A").bright.to_s]
          parts << "  #{layers_count} layers"
          parts << Rainbow("\xC2\xB7").color("#555555").to_s
          parts << Rainbow(" \xE2\x9D\x8C #{errors} error#{errors == 1 ? "" : "s"}").red.to_s if errors.positive?
          parts << Rainbow(" \xE2\x9A\xA0\xEF\xB8\x8F #{warnings} warning#{warnings == 1 ? "" : "s"}").yellow.to_s if warnings.positive?
          parts << Rainbow(" \xE2\x9C\x85 All checks passed").green.to_s if errors.zero? && warnings.zero?
          parts << Rainbow(" \xE2\x8F\xB1 #{report.duration_ms}ms").color("#888888").to_s

          parts.join("  ")
        end

        def severity_icon(severity)
          case severity
          when "error"   then Rainbow("\xE2\x9D\x8C").red
          when "warning" then Rainbow("\xE2\x9A\xA0\xEF\xB8\x8F").yellow
          when "info"    then Rainbow("\xE2\x84\xB9\xEF\xB8\x8F").blue
          when "notice"  then Rainbow("\xF0\x9F\x92\xA1").cyan
          else Rainbow("\xE2\x80\xA2")
          end
        end

        def line_suffix(issue)
          issue.line ? ":#{issue.line}" : ""
        end
      end
    end
  end
end
