# frozen_string_literal: true

require_relative 'validation_result'

module Uniword
  module Validation
    # Base class for link checkers.
    #
    # Responsibility: Define interface for link validation checkers.
    # Single Responsibility: Provide checker contract only.
    #
    # All link checkers inherit from this class and implement:
    # - can_check?(link): Can this checker validate this link?
    # - check(link, document): Perform validation
    #
    # This follows the Strategy pattern - different checkers for different
    # link types, all with the same interface.
    #
    # @example Create a custom checker
    #   class MyChecker < LinkChecker
    #     def can_check?(link)
    #       link.respond_to?(:custom_field)
    #     end
    #
    #     def check(link, document)
    #       # Validation logic
    #       ValidationResult.success(link)
    #     end
    #   end
    #
    # @abstract Subclass and override {#can_check?} and {#check}
    class LinkChecker
      # @return [Hash] Configuration for this checker
      attr_reader :config

      # Initialize a new LinkChecker.
      #
      # @param config [Hash] Configuration options
      #
      # @example Create a checker
      #   checker = LinkChecker.new(config: { timeout: 10 })
      def initialize(config: {})
        @config = config || {}
      end

      # Check if this checker can validate the given link.
      #
      # @param link [Object] The link to check
      # @return [Boolean] true if this checker can validate the link
      #
      # @example
      #   checker.can_check?(hyperlink) # => true
      #
      # @abstract Subclasses must implement this method
      def can_check?(link)
        raise NotImplementedError,
              "#{self.class}#can_check? must be implemented"
      end

      # Validate the given link.
      #
      # @param link [Object] The link to validate
      # @param document [Object] The document containing the link (for context)
      # @return [ValidationResult] The validation result
      #
      # @example
      #   result = checker.check(hyperlink, document)
      #
      # @abstract Subclasses must implement this method
      def check(link, document = nil)
        raise NotImplementedError,
              "#{self.class}#check must be implemented"
      end

      protected

      # Check if checker is enabled in configuration.
      #
      # @return [Boolean] true if enabled
      def enabled?
        @config.fetch(:enabled, true)
      end

      # Get configuration value with default.
      #
      # @param key [Symbol] Configuration key
      # @param default [Object] Default value
      # @return [Object] Configuration value or default
      def config_value(key, default = nil)
        @config.fetch(key, default)
      end
    end
  end
end
