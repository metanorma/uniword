# frozen_string_literal: true

# All Quality classes autoloaded via lib/uniword/quality.rb
# Configuration::ConfigurationLoader autoloaded via lib/uniword.rb

module Uniword
  module Quality
    # Coordinates document quality checking using configured rules.
    #
    # Responsibility: Load rules from configuration and orchestrate quality checks.
    # Single Responsibility - only coordinates rule execution and report generation.
    #
    # Follows Open/Closed Principle - new rules can be added via configuration
    # without modifying this class.
    #
    # @example Check document quality
    #   checker = DocumentChecker.new
    #   report = checker.check(document)
    #   puts report.valid? ? "OK" : "Issues found"
    #
    # @example Use custom rules file
    #   checker = DocumentChecker.new(rules_file: 'custom_rules.yml')
    #   report = checker.check(document)
    class DocumentChecker
      attr_reader :rules, :config

      # Rule class registry
      # Maps rule names to their class implementations
      RULE_CLASSES = {
        heading_hierarchy: "HeadingHierarchyRule",
        table_headers: "TableHeaderRule",
        paragraph_length: "ParagraphLengthRule",
        image_alt_text: "ImageAltTextRule",
        link_validation: "LinkValidationRule",
        style_consistency: "StyleConsistencyRule"
      }.freeze

      # Initialize document checker
      #
      # @param rules_file [String, nil] Path to rules configuration file
      # @param config [Hash, nil] Direct configuration hash (overrides rules_file)
      def initialize(rules_file: nil, config: nil)
        @config = load_configuration(rules_file, config)
        @rules = load_rules
      end

      # Check document for quality violations
      #
      # @param document [Document] The document to check
      # @return [QualityReport] Report containing all violations found
      def check(document)
        validate_document!(document)

        report = QualityReport.new

        # Execute each enabled rule
        rules.each do |rule|
          next unless rule.enabled?

          violations = rule.check(document)
          report.add_violations(violations)
        end

        report
      end

      # Get list of enabled rule names
      #
      # @return [Array<String>] Names of enabled rules
      def enabled_rules
        rules.select(&:enabled?).map(&:name)
      end

      # Get list of disabled rule names
      #
      # @return [Array<String>] Names of disabled rules
      def disabled_rules
        rules.reject(&:enabled?).map(&:name)
      end

      private

      # Load configuration from file or use provided config
      #
      # @param rules_file [String, nil] Path to rules file
      # @param config [Hash, nil] Direct configuration
      # @return [Hash] Loaded configuration
      def load_configuration(rules_file, config)
        if config
          # Use provided configuration
          config
        elsif rules_file
          # Load from specific file
          Configuration::ConfigurationLoader.load_file(rules_file)
        else
          # Load default quality_rules.yml
          Configuration::ConfigurationLoader.load("quality_rules")
        end
      rescue Configuration::ConfigurationError => e
        raise QualityCheckError,
              "Failed to load quality rules configuration: #{e.message}"
      end

      # Load and instantiate all configured rules
      #
      # @return [Array<QualityRule>] Array of rule instances
      def load_rules
        rules_config = @config[:quality_rules] || {}

        RULE_CLASSES.map do |rule_key, class_name|
          rule_config = rules_config[rule_key] || {}
          instantiate_rule(class_name, rule_config)
        end.compact
      end

      # Instantiate a rule class with configuration
      #
      # @param class_name [String] Name of the rule class
      # @param config [Hash] Rule configuration
      # @return [QualityRule, nil] Rule instance or nil if class not found
      def instantiate_rule(class_name, config)
        # Rule classes are autoloaded via lib/uniword/quality.rb
        rule_class = Quality.const_get(class_name)
        rule_class.new(config)
      rescue NameError => e
        # Rule class not found - skip it
        warn "Quality rule class not found: #{class_name} (#{e.message})"
        nil
      end

      # Validate document object
      #
      # @param document [Object] The document to validate
      # @raise [ArgumentError] if document is invalid
      def validate_document!(document)
        return if document.respond_to?(:paragraphs) && document.respond_to?(:tables)

        raise ArgumentError,
              "Document must respond to :paragraphs and :tables methods"
      end
    end

    # Error raised when quality checking fails
    class QualityCheckError < Error
      def initialize(message)
        super("Quality check error: #{message}")
      end
    end
  end
end
