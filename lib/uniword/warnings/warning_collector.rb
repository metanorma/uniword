# frozen_string_literal: true


module Uniword
  module Warnings
    # Collects warnings during document processing.
    #
    # Responsibility: Track unsupported elements and features.
    # Single Responsibility: Only collects warnings.
    #
    # This class is used during deserialization to track all unsupported
    # elements and attributes encountered, allowing users to understand
    # what features may be lost in round-trip operations.
    #
    # External configuration: config/warning_rules.yml
    #
    # @example Use during deserialization
    #   collector = WarningCollector.new
    #   collector.record_unsupported('chart', context: 'In paragraph 5')
    #   report = collector.report
    #   puts report.summary
    class WarningCollector
      # @return [Array<Warning>] Collected warnings
      attr_reader :warnings

      # @return [Hash<String, Integer>] Element occurrence counts
      attr_reader :element_counts

      # Initialize a new warning collector.
      #
      # @param config_file [String] Path to configuration file
      #
      # @example Create with default config
      #   collector = WarningCollector.new
      #
      # @example Create with custom config
      #   collector = WarningCollector.new(
      #     config_file: 'custom_warnings.yml'
      #   )
      def initialize(config_file: nil)
        @config = load_config(config_file)
        @warnings = []
        @element_counts = Hash.new(0)
      end

      # Record an unsupported element.
      #
      # @param element_tag [String] Element tag name
      # @param context [String] Context where element was found
      # @param location [String] Location in document (optional)
      # @return [void]
      #
      # @example Record unsupported element
      #   collector.record_unsupported(
      #     'chart',
      #     context: 'While parsing paragraph',
      #     location: '/document/body/p[5]'
      #   )
      def record_unsupported(element_tag, context:, location: nil)
        return unless enabled?
        return if max_warnings_reached?

        @element_counts[element_tag] += 1

        warning = Warning.new(
          type: :unsupported_element,
          severity: determine_severity(element_tag),
          element: element_tag,
          message: "Unsupported element: #{element_tag}",
          context: context,
          location: location,
          suggestion: get_suggestion(element_tag)
        )

        @warnings << warning
        log_warning(warning) if should_log?
      end

      # Record an unsupported attribute.
      #
      # @param element_tag [String] Element tag name
      # @param attribute_name [String] Attribute name
      # @param context [String] Context where attribute was found
      # @return [void]
      #
      # @example Record unsupported attribute
      #   collector.record_unsupported_attribute(
      #     'w:p',
      #     'customAttr',
      #     context: 'In paragraph properties'
      #   )
      def record_unsupported_attribute(element_tag, attribute_name, context:)
        return unless enabled?
        return if max_warnings_reached?

        warning = Warning.new(
          type: :unsupported_attribute,
          severity: :info,
          element: element_tag,
          attribute: attribute_name,
          message: "Unsupported attribute: #{element_tag}/@#{attribute_name}",
          context: context
        )

        @warnings << warning
        log_warning(warning) if should_log?
      end

      # Generate warning report.
      #
      # @return [WarningReport] Aggregated warning report
      #
      # @example Get report
      #   report = collector.report
      #   puts "Total warnings: #{report.total_count}"
      def report
        WarningReport.new(
          warnings: @warnings,
          element_counts: @element_counts,
          config: @config
        )
      end

      # Check if warnings were collected.
      #
      # @return [Boolean] true if warnings exist
      def any?
        @warnings.any?
      end

      # Clear all collected warnings.
      #
      # @return [void]
      def clear
        @warnings.clear
        @element_counts.clear
      end

      private

      def load_config(config_file)
        if config_file
          Configuration::ConfigurationLoader.load_file(config_file)
        else
          # Try to load default config
          default_path = File.join(
            Configuration::ConfigurationLoader::CONFIG_DIR,
            'warning_rules.yml'
          )

          if File.exist?(default_path)
            Configuration::ConfigurationLoader.load('warning_rules')
          else
            # Use empty config with defaults
            default_config
          end
        end
      rescue Configuration::ConfigurationError
        # If config fails to load, use defaults
        default_config
      end

      def default_config
        {
          warning_system: {
            enabled: true,
            log_warnings: false,
            log_level: :warn,
            critical_elements: [],
            warning_elements: [],
            element_suggestions: {},
            reporting: {
              max_warnings: 100
            }
          }
        }
      end

      def warning_config
        @config[:warning_system] || {}
      end

      def enabled?
        warning_config[:enabled] != false
      end

      def should_log?
        warning_config[:log_warnings] == true
      end

      def max_warnings_reached?
        max = warning_config.dig(:reporting, :max_warnings) || 100
        @warnings.count >= max
      end

      def determine_severity(element_tag)
        critical = warning_config[:critical_elements] || []
        warning_els = warning_config[:warning_elements] || []

        if critical.include?(element_tag)
          :error
        elsif warning_els.include?(element_tag)
          :warning
        else
          :info
        end
      end

      def get_suggestion(element_tag)
        suggestions = warning_config[:element_suggestions] || {}
        suggestions[element_tag] ||
          suggestions[element_tag.to_sym] ||
          'This element is not yet supported. Data may be lost in round-trip.'
      end

      def log_warning(warning)
        level = warning_config[:log_level] || :warn
        message = "[WARNING] #{warning}"

        # Use Uniword logger if available
        if defined?(Uniword::Logger)
          Uniword::Logger.send(level, message)
        elsif %i[warn error].include?(level)
          # Fall back to standard output
          puts message
        end
      end
    end
  end
end
