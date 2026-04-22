# frozen_string_literal: true

require "zip"
require "nokogiri"
require_relative "../rules"
require_relative "../report/validation_issue"
# LayerValidator autoloaded via lib/uniword/validation.rb

module Uniword
  module Validation
    module Validators
      # Validates document semantic structure using extensible rules.
      #
      # Uses the Rules::Registry to discover and apply validation rules.
      # Users can register custom rules via Rules::Registry.register(MyRule).
      #
      # This is Layer 7 validation — validates cross-part references,
      # content integrity, and structural consistency.
      #
      # @example Validate with default rules
      #   validator = DocumentSemanticsValidator.new
      #   result = validator.validate('document.docx')
      class DocumentSemanticsValidator < LayerValidator
        WORDML_NAMESPACE = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"

        def layer_name
          "Document Semantics"
        end

        def validate(path)
          issues = []

          context = Rules::DocumentContext.new(path)
          begin
            rules = Rules::Registry.all
            rules.each do |rule|
              next unless rule.applicable?(context)

              issues.concat(rule.check(context))
            end
          ensure
            context.close
          end

          build_result(issues)
        rescue StandardError => e
          issues << Report::ValidationIssue.new(
            severity: "error",
            code: "DOC-000",
            message: "Semantic validation failed: #{e.message}"
          )
          build_result(issues)
        end

        private

        def build_result(issues)
          result = LayerValidationResult.new(layer_name)
          issues.each do |issue|
            case issue.severity
            when "error" then result.add_error("[#{issue.code}] #{issue.message}")
            when "warning" then result.add_warning("[#{issue.code}] #{issue.message}")
            else result.add_info("[#{issue.code}] #{issue.message}")
            end
          end
          result
        end
      end
    end
  end
end
