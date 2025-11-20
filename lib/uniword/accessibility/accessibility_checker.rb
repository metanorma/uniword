# frozen_string_literal: true

require "yaml"

module Uniword
  module Accessibility
    # Accessibility Checker - validate document accessibility compliance
    #
    # Responsibility: Orchestrate accessibility checking with profiles
    # Single Responsibility: Accessibility validation orchestration only
    #
    # External config: config/accessibility_profiles.yml
    #
    # @example Check document accessibility
    #   checker = AccessibilityChecker.new(profile: :wcag_2_1_aa)
    #   report = checker.check(document)
    #   puts report.summary
    #   report.export_html('accessibility_report.html')
    class AccessibilityChecker
      attr_reader :profile, :rules

      # Initialize a new accessibility checker
      #
      # @param profile [Symbol] Profile name to use
      # @param config_file [String] Path to configuration file
      # @raise [ArgumentError] If profile not found
      def initialize(profile: :wcag_2_1_aa, config_file: nil)
        @profile_name = profile
        @config_file = config_file || default_config_path
        @config = load_config
        @profile = AccessibilityProfile.load(@config, @profile_name)
        @rules = initialize_rules
      end

      # Check document for accessibility compliance
      #
      # @param document [Document] Document to check
      # @return [AccessibilityReport] Detailed compliance report
      def check(document)
        report = AccessibilityReport.new(
          profile_name: @profile.name,
          profile_level: @profile.level
        )

        # Run all enabled rules
        @rules.each do |rule|
          next unless rule.enabled?

          violations = rule.check(document)
          violations.each { |v| report.add_violation(v) }
        end

        report
      end

      # Quick compliance check (boolean)
      #
      # @param document [Document] Document to check
      # @return [Boolean] True if compliant (no errors)
      def compliant?(document)
        check(document).compliant?
      end

      private

      # Load configuration from YAML file
      #
      # @return [Hash] Parsed configuration
      # @raise [Errno::ENOENT] If config file not found
      def load_config
        YAML.load_file(@config_file, symbolize_names: true)
      end

      # Get default configuration file path
      #
      # @return [String] Default config path
      def default_config_path
        File.expand_path("../../../config/accessibility_profiles.yml", __dir__)
      end

      # Initialize rules based on profile configuration
      #
      # @return [Array<AccessibilityRule>] Initialized rules
      def initialize_rules
        [
          # WCAG 1.1.1: Non-text Content
          Rules::ImageAltTextRule.new(@profile.rule_config(:image_alt_text)),

          # WCAG 1.3.1: Info and Relationships
          Rules::HeadingStructureRule.new(@profile.rule_config(:heading_structure)),
          Rules::TableHeadersRule.new(@profile.rule_config(:table_headers)),
          Rules::ListStructureRule.new(@profile.rule_config(:list_structure)),

          # WCAG 1.3.2: Meaningful Sequence
          Rules::ReadingOrderRule.new(@profile.rule_config(:reading_order)),

          # WCAG 1.4.1: Use of Color
          Rules::ColorUsageRule.new(@profile.rule_config(:color_usage)),

          # WCAG 1.4.3: Contrast (Minimum)
          Rules::ContrastRatioRule.new(@profile.rule_config(:contrast_ratio)),

          # WCAG 2.4.2: Page Titled
          Rules::DocumentTitleRule.new(@profile.rule_config(:document_title)),

          # WCAG 2.4.6: Headings and Labels
          Rules::DescriptiveHeadingsRule.new(@profile.rule_config(:descriptive_headings)),

          # WCAG 3.1.1: Language of Page
          Rules::LanguageSpecificationRule.new(@profile.rule_config(:language_specification))
        ].compact
      end
    end
  end
end