# frozen_string_literal: true

module Uniword
  module Warnings
    # Represents a single warning about an unsupported element or feature.
    #
    # Responsibility: Store information about one warning.
    # Single Responsibility: Only represents warning data.
    #
    # A warning includes:
    # - Type (unsupported_element, unsupported_attribute, etc.)
    # - Severity (error, warning, info)
    # - Element/attribute name
    # - Context where it was encountered
    # - Location in document
    # - Suggestion for user
    #
    # @example Create a warning
    #   warning = Warning.new(
    #     type: :unsupported_element,
    #     severity: :warning,
    #     element: 'chart',
    #     message: 'Unsupported element: chart',
    #     context: 'While parsing paragraph',
    #     suggestion: 'Chart will be preserved but not editable'
    #   )
    class Warning
      # @return [Symbol] Type of warning
      attr_reader :type

      # @return [Symbol] Severity level (:error, :warning, :info)
      attr_reader :severity

      # @return [String] Element name
      attr_reader :element

      # @return [String, nil] Attribute name (for attribute warnings)
      attr_reader :attribute

      # @return [String] Warning message
      attr_reader :message

      # @return [String, nil] Context where warning occurred
      attr_reader :context

      # @return [String, nil] Location in document
      attr_reader :location

      # @return [String, nil] Suggestion for user
      attr_reader :suggestion

      # Initialize a new warning.
      #
      # @param attributes [Hash] Warning attributes
      # @option attributes [Symbol] :type Warning type
      # @option attributes [Symbol] :severity Severity level
      # @option attributes [String] :element Element name
      # @option attributes [String] :attribute Attribute name (optional)
      # @option attributes [String] :message Warning message
      # @option attributes [String] :context Context (optional)
      # @option attributes [String] :location Location (optional)
      # @option attributes [String] :suggestion Suggestion (optional)
      #
      # @example Create a warning
      #   warning = Warning.new(
      #     type: :unsupported_element,
      #     severity: :error,
      #     element: 'chart',
      #     message: 'Unsupported element: chart'
      #   )
      def initialize(attributes)
        @type = attributes[:type]
        @severity = attributes[:severity]
        @element = attributes[:element]
        @attribute = attributes[:attribute]
        @message = attributes[:message]
        @context = attributes[:context]
        @location = attributes[:location]
        @suggestion = attributes[:suggestion]
      end

      # Check if this is an error-level warning.
      #
      # @return [Boolean] true if severity is :error
      def error?
        @severity == :error
      end

      # Check if this is a warning-level warning.
      #
      # @return [Boolean] true if severity is :warning
      def warning?
        @severity == :warning
      end

      # Check if this is an info-level warning.
      #
      # @return [Boolean] true if severity is :info
      def info?
        @severity == :info
      end

      # Convert to hash representation.
      #
      # @return [Hash] Hash representation
      def to_h
        {
          type: @type,
          severity: @severity,
          element: @element,
          attribute: @attribute,
          message: @message,
          context: @context,
          location: @location,
          suggestion: @suggestion
        }.compact
      end

      # Convert to string for display.
      #
      # @return [String] String representation
      def to_s
        severity_str = @severity.to_s.upcase
        element_str = @attribute ? "#{@element}/@#{@attribute}" : @element
        msg_str = @message
        "[#{severity_str}] #{element_str}: #{msg_str}"
      end
    end
  end
end
