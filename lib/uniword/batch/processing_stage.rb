# frozen_string_literal: true

module Uniword
  module Batch
    # Base class for batch processing pipeline stages.
    #
    # Responsibility: Define the interface for processing pipeline stages.
    # Each stage performs one specific transformation or validation on a document.
    #
    # Follows Single Responsibility Principle - one stage does one transformation.
    # Follows Open/Closed Principle - new stages can be added without modifying this class.
    #
    # @example Create a custom processing stage
    #   class CustomStage < ProcessingStage
    #     def initialize(options = {})
    #       super(options)
    #       @threshold = options[:threshold] || 100
    #     end
    #
    #     def process(document, context = {})
    #       # Perform transformation
    #       # Return modified document or original
    #       document
    #     end
    #   end
    class ProcessingStage
      attr_reader :options, :enabled

      # Initialize processing stage
      #
      # @param options [Hash] Stage configuration options
      # @option options [Boolean] :enabled Whether stage is enabled (default: true)
      def initialize(options = {})
        @options = options || {}
        @enabled = @options.fetch(:enabled, true)
      end

      # Check if stage is enabled
      #
      # @return [Boolean] true if stage should be executed
      def enabled?
        @enabled
      end

      # Process a document through this stage
      #
      # @param document [Document] The document to process
      # @param context [Hash] Processing context (file paths, metadata, etc.)
      # @return [Document] The processed document (may be modified or original)
      # @raise [NotImplementedError] if not implemented by subclass
      def process(document, context = {})
        raise NotImplementedError, "#{self.class} must implement #process"
      end

      # Get stage name (used for identification and logging)
      #
      # @return [String] Stage name
      def name
        self.class.name.split("::").last
          .gsub(/Stage$/, "")
          .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
          .gsub(/([a-z\d])([A-Z])/, '\1_\2')
          .downcase
      end

      # Get stage description (for logging and reporting)
      #
      # @return [String] Stage description
      def description
        "#{name} stage"
      end

      protected

      # Log a message during processing
      #
      # @param message [String] Message to log
      # @param level [Symbol] Log level (:info, :warn, :error)
      def log(message, level: :info)
        prefix = "[#{name}]"
        case level
        when :error
          warn "ERROR #{prefix} #{message}"
        when :warn
          warn "WARN #{prefix} #{message}"
        else
          puts "INFO #{prefix} #{message}" if ENV["UNIWORD_VERBOSE"]
        end
      end
    end
  end
end
