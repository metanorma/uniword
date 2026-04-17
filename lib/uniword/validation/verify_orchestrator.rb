# frozen_string_literal: true

require "time"
require_relative "opc_validator"
require_relative "schema_registry"
require_relative "report/verification_report"
require_relative "report/layer_result"
require_relative "report/terminal_formatter"
require_relative "validators/xml_schema_validator"
require_relative "validators/document_semantics_validator"

module Uniword
  module Validation
    # Orchestrates the three-layer DOCX verification process.
    #
    # Coordinates:
    # 1. OPC Package validation (ZIP, content types, relationships)
    # 2. XSD Schema validation (namespace-aware, using Moxml + Nokogiri)
    # 3. Word Document semantic validation (extensible rule system)
    #
    # Returns a VerificationReport that can be serialized to JSON/YAML
    # or formatted for terminal output.
    #
    # @example Verify a DOCX file
    #   orchestrator = VerifyOrchestrator.new
    #   report = orchestrator.verify("document.docx")
    #   puts report.to_json
    #   puts TerminalFormatter.new.format(report)
    class VerifyOrchestrator
      attr_reader :xsd_validation

      # Initialize the orchestrator.
      #
      # @param xsd_validation [Boolean] Enable XSD schema validation
      def initialize(xsd_validation: false)
        @xsd_validation = xsd_validation
      end

      # Verify a DOCX file.
      #
      # @param path [String] Path to .docx file
      # @return [Report::VerificationReport] Verification results
      def verify(path)
        start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        layers = []

        # Layer 1: OPC Package
        opc_layer = run_opc_layer(path)
        layers << opc_layer

        # Only skip downstream layers for critical OPC failures:
        # ZIP can't be opened (OPC-001) or word/document.xml missing (OPC-004)
        critical_failure = opc_layer.issues.any? do |i|
          i.code == "OPC-001" || i.code == "OPC-004"
        end

        if critical_failure
          layers << Report::LayerResult.new(
            name: "XSD Schema", status: "skipped", duration_ms: 0, issues: []
          )
          layers << Report::LayerResult.new(
            name: "Word Document", status: "skipped", duration_ms: 0, issues: []
          )
        else
          layers << run_xsd_layer(path)
          layers << run_semantic_layer(path)
        end

        end_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        total_ms = ((end_time - start_time) * 1000).round

        Report::VerificationReport.new(
          file_path: path,
          valid: layers.all?(&:pass?),
          duration_ms: total_ms,
          layers: layers
        )
      end

      private

      def run_opc_layer(path)
        start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        validator = OpcValidator.new
        issues = validator.validate(path)
        duration = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start) * 1000).round

        status = issues.any? { |i| i.severity == "error" } ? "fail" : "pass"

        Report::LayerResult.new(
          name: "OPC Package",
          status: status,
          duration_ms: duration,
          issues: issues
        )
      end

      def run_xsd_layer(path)
        start = Process.clock_gettime(Process::CLOCK_MONOTONIC)

        config = @xsd_validation ? { "xml_schema" => { "xsd_validation" => true } } : {}
        validator = Validators::XmlSchemaValidator.new(config)
        result = validator.validate(path)

        duration = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start) * 1000).round

        # Extract issues from the LayerValidationResult
        issues = extract_issues(result)

        Report::LayerResult.new(
          name: "XSD Schema",
          status: result.valid? ? "pass" : "fail",
          duration_ms: duration,
          issues: issues
        )
      end

      def run_semantic_layer(path)
        start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        validator = Validators::DocumentSemanticsValidator.new
        result = validator.validate(path)
        duration = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start) * 1000).round

        issues = extract_issues(result)

        Report::LayerResult.new(
          name: "Word Document",
          status: result.valid? ? "pass" : "fail",
          duration_ms: duration,
          issues: issues
        )
      end

      def extract_issues(layer_result)
        # LayerValidationResult stores issues as error/warning/info hashes
        # We need to convert them to ValidationIssue objects
        issues = []
        layer_result.errors.each do |err|
          issues << Report::ValidationIssue.new(
            severity: "error",
            code: extract_code(err[:message]),
            message: clean_message(err[:message])
          )
        end
        layer_result.warnings.each do |warn|
          issues << Report::ValidationIssue.new(
            severity: "warning",
            code: extract_code(warn[:message]),
            message: clean_message(warn[:message])
          )
        end
        layer_result.infos.each do |info|
          issues << Report::ValidationIssue.new(
            severity: "info",
            code: extract_code(info[:message]),
            message: clean_message(info[:message])
          )
        end
        issues
      end

      def extract_code(message)
        match = message.match(/\[([A-Z]+-\d+)\]/)
        match ? match[1] : "UNK-000"
      end

      def clean_message(message)
        message.gsub(/\[[A-Z]+-\d+\]\s*/, "")
      end
    end
  end
end
