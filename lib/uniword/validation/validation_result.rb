# frozen_string_literal: true

module Uniword
  module Validation
    # Represents the result of validating a single link or reference.
    #
    # Responsibility: Store validation outcome for a single link check.
    # Single Responsibility: Only represents validation results.
    #
    # A validation result includes:
    # - Status (success, failure, warning)
    # - The link being validated
    # - Error message if validation failed
    # - Optional metadata
    #
    # @example Create a success result
    #   result = ValidationResult.success(hyperlink)
    #
    # @example Create a failure result
    #   result = ValidationResult.failure(hyperlink, "URL not accessible")
    #
    # @example Create a warning result
    #   result = ValidationResult.warning(hyperlink, "Slow response time")
    class ValidationResult
      # @return [Symbol] Status of validation (:success, :failure, :warning)
      attr_reader :status

      # @return [Object] The link or reference being validated
      attr_reader :link

      # @return [String, nil] Error or warning message
      attr_reader :message

      # @return [Hash] Additional metadata
      attr_reader :metadata

      # Initialize a new ValidationResult.
      #
      # @param status [Symbol] Validation status (:success, :failure, :warning)
      # @param link [Object] The link being validated
      # @param message [String, nil] Error or warning message
      # @param metadata [Hash] Additional metadata
      #
      # @example Create a result
      #   result = ValidationResult.new(
      #     status: :failure,
      #     link: hyperlink,
      #     message: "404 Not Found"
      #   )
      def initialize(status:, link:, message: nil, metadata: {})
        @status = status
        @link = link
        @message = message
        @metadata = metadata || {}
      end

      # Factory method: Create a success result.
      #
      # @param link [Object] The validated link
      # @param metadata [Hash] Optional metadata
      # @return [ValidationResult] Success result
      #
      # @example
      #   result = ValidationResult.success(hyperlink)
      def self.success(link, metadata: {})
        new(status: :success, link: link, metadata: metadata)
      end

      # Factory method: Create a failure result.
      #
      # @param link [Object] The validated link
      # @param message [String] Error message
      # @param metadata [Hash] Optional metadata
      # @return [ValidationResult] Failure result
      #
      # @example
      #   result = ValidationResult.failure(hyperlink, "URL not found")
      def self.failure(link, message, metadata: {})
        new(status: :failure, link: link, message: message, metadata: metadata)
      end

      # Factory method: Create a warning result.
      #
      # @param link [Object] The validated link
      # @param message [String] Warning message
      # @param metadata [Hash] Optional metadata
      # @return [ValidationResult] Warning result
      #
      # @example
      #   result = ValidationResult.warning(hyperlink, "Redirect detected")
      def self.warning(link, message, metadata: {})
        new(status: :warning, link: link, message: message, metadata: metadata)
      end

      # Factory method: Create an unknown/skipped result.
      #
      # @param link [Object] The link that was skipped
      # @param message [String] Optional explanation
      # @param metadata [Hash] Optional metadata
      # @return [ValidationResult] Unknown result
      #
      # @example
      #   result = ValidationResult.unknown(hyperlink, "No checker available")
      def self.unknown(link, message = "No checker available", metadata: {})
        new(status: :unknown, link: link, message: message, metadata: metadata)
      end

      # Check if validation was successful.
      #
      # @return [Boolean] true if status is :success
      #
      # @example
      #   result.valid? # => true
      def valid?
        @status == :success
      end

      # Check if validation failed.
      #
      # @return [Boolean] true if status is :failure
      #
      # @example
      #   result.failure? # => false
      def failure?
        @status == :failure
      end

      # Check if validation produced a warning.
      #
      # @return [Boolean] true if status is :warning
      #
      # @example
      #   result.warning? # => false
      def warning?
        @status == :warning
      end

      # Check if validation status is unknown.
      #
      # @return [Boolean] true if status is :unknown
      #
      # @example
      #   result.unknown? # => false
      def unknown?
        @status == :unknown
      end

      # Get the link identifier (URL, anchor, etc.).
      #
      # @return [String] Link identifier
      #
      # @example
      #   result.link_identifier # => "https://example.com"
      def link_identifier
        if @link.respond_to?(:url) && @link.url
          @link.url
        elsif @link.respond_to?(:anchor) && @link.anchor
          "##{@link.anchor}"
        elsif @link.respond_to?(:id)
          @link.id.to_s
        elsif @link.respond_to?(:name)
          @link.name
        else
          @link.to_s
        end
      end

      # Get error message (alias for message).
      #
      # @return [String, nil] Error message
      #
      # @example
      #   result.error_message # => "URL not found"
      def error_message
        @message
      end

      # Convert to hash representation.
      #
      # @return [Hash] Hash representation
      #
      # @example
      #   result.to_h # => { status: :success, link: "...", ... }
      def to_h
        {
          status: @status,
          link: link_identifier,
          message: @message,
          metadata: @metadata,
        }.compact
      end

      # Convert to string for display.
      #
      # @return [String] String representation
      #
      # @example
      #   result.to_s # => "[SUCCESS] https://example.com"
      def to_s
        status_str = @status.to_s.upcase
        link_str = link_identifier
        msg_str = @message ? ": #{@message}" : ""
        "[#{status_str}] #{link_str}#{msg_str}"
      end

      # Detailed inspection for debugging.
      #
      # @return [String] Detailed representation
      def inspect
        "#<ValidationResult status=#{@status} link=#{link_identifier.inspect} " \
          "message=#{@message.inspect}>"
      end
    end
  end
end
