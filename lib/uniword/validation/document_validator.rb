# frozen_string_literal: true

require 'json'
require_relative '../configuration/configuration_loader'
require_relative 'layer_validator'
require_relative 'layer_validation_result'
require_relative 'validators/file_structure_validator'
require_relative 'validators/zip_integrity_validator'
require_relative 'validators/ooxml_part_validator'
require_relative 'validators/xml_schema_validator'
require_relative 'validators/relationship_validator'
require_relative 'validators/content_type_validator'
require_relative 'validators/document_semantics_validator'

module Uniword
  module Validation
    # Main document validator orchestrator.
    #
    # Responsibility: Orchestrate 7-layer document validation.
    # Single Responsibility: Only coordinates validation layers.
    #
    # Validates Word documents at 7 layers (MECE):
    # 1. File Structure - file exists, readable, valid extension
    # 2. ZIP Integrity - valid archive, no corruption
    # 3. OOXML Parts - required parts present
    # 4. XML Schema - well-formed XML
    # 5. Relationships - valid references
    # 6. Content Types - consistent type declarations
    # 7. Document Semantics - valid document structure
    #
    # External configuration: config/validation_rules.yml
    #
    # @example Basic validation
    #   validator = DocumentValidator.new
    #   report = validator.validate('document.docx')
    #   puts report.valid? # => true
    #
    # @example Custom configuration
    #   validator = DocumentValidator.new(
    #     config_file: 'custom_validation.yml'
    #   )
    #   report = validator.validate('document.docx')
    class DocumentValidator
      # @return [Hash] Configuration
      attr_reader :config

      # @return [Array<LayerValidator>] Validators
      attr_reader :validators

      # Initialize document validator.
      #
      # @param config_file [String] Path to configuration file
      #
      # @example Create with default config
      #   validator = DocumentValidator.new
      #
      # @example Create with custom config
      #   validator = DocumentValidator.new(
      #     config_file: 'config/custom_validation.yml'
      #   )
      def initialize(config_file: nil)
        @config = load_config(config_file)
        @validators = initialize_validators
      end

      # Validate a document file.
      #
      # Runs all enabled validators in sequence. Can fail-fast on
      # critical errors if configured.
      #
      # @param path [String] Path to .docx file
      # @return [DocumentValidationReport] Validation results
      #
      # @example Validate a document
      #   report = validator.validate('document.docx')
      #   if report.valid?
      #     puts "Document is valid!"
      #   else
      #     puts "Errors: #{report.errors.count}"
      #   end
      def validate(path)
        report = DocumentValidationReport.new(path)

        @validators.each do |validator|
          next unless validator.enabled?

          result = validator.validate(path)
          report.add_layer_result(validator.layer_name, result)

          # Fail fast if critical failure and configured to do so
          if result.critical_failures? && fail_fast?
            break
          end
        end

        report
      end

      # Quick validity check (boolean).
      #
      # @param path [String] Path to .docx file
      # @return [Boolean] true if document is valid
      #
      # @example Quick check
      #   if validator.valid?('document.docx')
      #     # Process document
      #   end
      def valid?(path)
        validate(path).valid?
      end

      private

      def load_config(config_file)
        if config_file
          Configuration::ConfigurationLoader.load_file(config_file)
        else
          # Try to load default config
          default_path = File.join(
            Configuration::ConfigurationLoader::CONFIG_DIR,
            'validation_rules.yml'
          )

          if File.exist?(default_path)
            Configuration::ConfigurationLoader.load('validation_rules')
          else
            # Use empty config with defaults
            { document_validation: { fail_fast: true } }
          end
        end
      rescue Configuration::ConfigurationError
        # If config fails to load, use defaults
        { document_validation: { fail_fast: true } }
      end

      def initialize_validators
        config_hash = @config[:document_validation] || @config

        [
          Validators::FileStructureValidator.new(config_hash),
          Validators::ZipIntegrityValidator.new(config_hash),
          Validators::OoxmlPartValidator.new(config_hash),
          Validators::XmlSchemaValidator.new(config_hash),
          Validators::RelationshipValidator.new(config_hash),
          Validators::ContentTypeValidator.new(config_hash),
          Validators::DocumentSemanticsValidator.new(config_hash)
        ]
      end

      def fail_fast?
        validation_config = @config[:document_validation] || {}
        validation_config[:fail_fast] != false
      end
    end

    # Validation report for document validation.
    #
    # Aggregates results from all validation layers.
    class DocumentValidationReport
      # @return [String] Path to validated file
      attr_reader :file_path

      # @return [Hash<String, LayerValidationResult>] Results by layer
      attr_reader :layer_results

      # Initialize a new report.
      #
      # @param file_path [String] Path to validated file
      def initialize(file_path)
        @file_path = file_path
        @layer_results = {}
      end

      # Add a layer validation result.
      #
      # @param layer_name [String] Name of validation layer
      # @param result [LayerValidationResult] Validation result
      # @return [void]
      def add_layer_result(layer_name, result)
        @layer_results[layer_name] = result
      end

      # Check if document is valid overall.
      #
      # @return [Boolean] true if all layers passed
      def valid?
        @layer_results.values.all?(&:valid?)
      end

      # Get all errors from all layers.
      #
      # @return [Array<Hash>] All errors with layer info
      def errors
        @layer_results.flat_map do |layer, result|
          result.errors.map { |err| err.merge(layer: layer) }
        end
      end

      # Get all warnings from all layers.
      #
      # @return [Array<Hash>] All warnings with layer info
      def warnings
        @layer_results.flat_map do |layer, result|
          result.warnings.map { |warn| warn.merge(layer: layer) }
        end
      end

      # Get all info messages from all layers.
      #
      # @return [Array<Hash>] All info messages with layer info
      def infos
        @layer_results.flat_map do |layer, result|
          result.infos.map { |info| info.merge(layer: layer) }
        end
      end

      # Check if any layer has critical failures.
      #
      # @return [Boolean] true if critical failures exist
      def critical_failures?
        @layer_results.values.any?(&:critical_failures?)
      end

      # Get summary statistics.
      #
      # @return [Hash] Summary data
      def summary
        {
          file: @file_path,
          valid: valid?,
          layers_validated: @layer_results.count,
          errors: errors.count,
          warnings: warnings.count,
          infos: infos.count,
          critical: critical_failures?
        }
      end

      # Export to JSON string.
      #
      # @return [String] JSON representation
      def to_json(*_args)
        JSON.pretty_generate(
          summary: summary,
          layers: @layer_results.transform_values(&:to_h)
        )
      end

      # Convert to string for display.
      #
      # @return [String] String representation
      def to_s
        lines = [
          "Document Validation Report: #{@file_path}",
          "=" * 60,
          ""
        ]

        @layer_results.each do |layer_name, result|
          lines << result.to_s
        end

        lines << ""
        lines << "Summary:"
        lines << "  Valid: #{valid?}"
        lines << "  Errors: #{errors.count}"
        lines << "  Warnings: #{warnings.count}"
        lines << "  Info: #{infos.count}"

        if errors.any?
          lines << ""
          lines << "Errors:"
          errors.each do |error|
            lines << "  [#{error[:layer]}] #{error[:message]}"
          end
        end

        lines.join("\n")
      end
    end
  end
end