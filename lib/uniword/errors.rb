# frozen_string_literal: true

module Uniword
  # Base error class for all Uniword errors
  class Error < StandardError; end

  # Raised when a file is not found
  class FileNotFoundError < Error
    # @param path [String] The file path that was not found
    def initialize(path)
      super("File not found: #{path}")
      @path = path
    end

    # @return [String] The file path
    attr_reader :path
  end

  # Raised when a file format is invalid or unsupported
  class InvalidFormatError < Error
    # @param path [String] The file path
    # @param format [Symbol, String] The invalid format
    def initialize(path, format)
      super("Invalid or unsupported format '#{format}' for file: #{path}")
      @path = path
      @format = format
    end

    # @return [String] The file path
    attr_reader :path

    # @return [Symbol, String] The format
    attr_reader :format
  end

  # Raised when a file is corrupted or malformed
  class CorruptedFileError < Error
    # @param path [String] The file path
    # @param reason [String] The reason for corruption
    def initialize(path, reason)
      super("Corrupted file #{path}: #{reason}")
      @path = path
      @reason = reason
    end

    # @return [String] The file path
    attr_reader :path

    # @return [String] The reason
    attr_reader :reason
  end

  # Raised when element validation fails
  class ValidationError < Error
    # @param element [Element] The element that failed validation
    # @param errors [Array<String>] Array of validation error messages
    def initialize(element, errors)
      element_name = element.class.name.split("::").last
      super("Validation failed for #{element_name}: #{errors.join(', ')}")
      @element = element
      @errors = errors
    end

    # @return [Element] The element that failed
    attr_reader :element

    # @return [Array<String>] The validation errors
    attr_reader :errors
  end

  # Raised when trying to write to a read-only document
  class ReadOnlyError < Error
    # @param operation [String] The operation that was attempted
    def initialize(operation)
      super("Cannot perform '#{operation}' on read-only document")
      @operation = operation
    end

    # @return [String] The operation
    attr_reader :operation
  end

  # Raised when a required dependency is missing
  class DependencyError < Error
    # @param gem_name [String] The name of the missing gem
    # @param feature [String] The feature that requires it
    def initialize(gem_name, feature)
      super("Missing dependency '#{gem_name}' required for #{feature}. Install with: gem install #{gem_name}")
      @gem_name = gem_name
      @feature = feature
    end

    # @return [String] The gem name
    attr_reader :gem_name

    # @return [String] The feature
    attr_reader :feature
  end

  # Raised when an unsupported operation is attempted
  class UnsupportedOperationError < Error
    # @param operation [String] The unsupported operation
    # @param context [String] Additional context
    def initialize(operation, context = nil)
      message = "Unsupported operation: #{operation}"
      message += " (#{context})" if context
      super(message)
      @operation = operation
      @context = context
    end

    # @return [String] The operation
    attr_reader :operation

    # @return [String, nil] The context
    attr_reader :context
  end

  # Raised when a conversion between formats fails
  class ConversionError < Error
    # @param from_format [Symbol] The source format
    # @param to_format [Symbol] The target format
    # @param reason [String] The reason for failure
    def initialize(from_format, to_format, reason)
      super("Cannot convert from #{from_format} to #{to_format}: #{reason}")
      @from_format = from_format
      @to_format = to_format
      @reason = reason
    end

    # @return [Symbol] The source format
    attr_reader :from_format

    # @return [Symbol] The target format
    attr_reader :to_format

    # @return [String] The reason
    attr_reader :reason
  end
end
