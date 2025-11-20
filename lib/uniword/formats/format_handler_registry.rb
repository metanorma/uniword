# frozen_string_literal: true

require_relative 'base_handler'

module Uniword
  module Formats
    # Registry for format handlers.
    #
    # This class provides a centralized registry for mapping format identifiers
    # to their respective handler classes. It follows the Open-Closed Principle
    # by allowing new formats to be added without modifying existing code.
    #
    # @example Registering a custom handler
    #   Uniword::Formats::FormatHandlerRegistry.register(:pdf, PdfHandler)
    #
    # @example Getting a handler for a format
    #   handler = Uniword::Formats::FormatHandlerRegistry.handler_for(:docx)
    #   document = handler.read("document.docx")
    class FormatHandlerRegistry
      class << self
        # Register a format handler.
        #
        # @param format [Symbol] The format identifier (e.g., :docx, :mhtml)
        # @param handler_class [Class] The handler class
        # @return [void]
        # @raise [ArgumentError] if format is not a symbol
        # @raise [ArgumentError] if handler_class doesn't inherit from BaseHandler
        #
        # @example Register a custom handler
        #   FormatHandlerRegistry.register(:pdf, PdfHandler)
        def register(format, handler_class)
          validate_format(format)
          validate_handler_class(handler_class)

          registry[format] = handler_class
        end

        # Get a handler instance for a format.
        #
        # @param format [Symbol] The format identifier
        # @return [BaseHandler] An instance of the handler class
        # @raise [ArgumentError] if format is not registered
        #
        # @example Get a handler
        #   handler = FormatHandlerRegistry.handler_for(:docx)
        def handler_for(format)
          validate_format(format)
          ensure_handlers_registered

          handler_class = registry[format]
          unless handler_class
            raise ArgumentError,
                  "No handler registered for format: #{format}. " \
                  "Available formats: #{registered_formats.join(', ')}"
          end

          handler_class.new
        end

        # Get a handler instance for a file based on its extension.
        #
        # @param path [String] The file path
        # @return [BaseHandler] An instance of the appropriate handler
        # @raise [ArgumentError] if no handler can handle the file
        #
        # @example Get a handler for a file
        #   handler = FormatHandlerRegistry.handler_for_file("document.docx")
        def handler_for_file(path)
          raise ArgumentError, 'Path cannot be nil' if path.nil?
          raise ArgumentError, 'Path cannot be empty' if path.to_s.empty?

          ensure_handlers_registered

          registry.each_value do |handler_class|
            handler = handler_class.new
            return handler if handler.can_handle?(path)
          end

          raise ArgumentError,
                "No handler found for file: #{path}. " \
                "Registered formats: #{registered_formats.join(', ')}"
        end

        # Check if a format is registered.
        #
        # @param format [Symbol] The format identifier
        # @return [Boolean] true if the format is registered
        def registered?(format)
          registry.key?(format)
        end

        # Get all registered formats.
        #
        # @return [Array<Symbol>] Array of registered format identifiers
        def registered_formats
          registry.keys
        end

        # Get the registry hash.
        #
        # @return [Hash<Symbol, Class>] The registry mapping formats to handlers
        def registry
          @registry ||= {}
        end

        # Reset the registry (useful for testing).
        #
        # @return [void]
        def reset_registry
          @registry = {}
          @handlers_registered = false
        end

        private

        # Ensure format handlers are registered.
        #
        # This method implements lazy registration - handlers are only loaded
        # and registered when first needed. This ensures handlers are available
        # even if the main library file wasn't required.
        #
        # @return [void]
        def ensure_handlers_registered
          return if @handlers_registered

          # Require handler files to trigger their self-registration
          require_relative 'docx_handler'
          require_relative 'mhtml_handler'

          # Manually register handlers in case files were already loaded
          # (e.g., after reset_registry in tests)
          register(:docx, DocxHandler) unless registered?(:docx)
          register(:mhtml, MhtmlHandler) unless registered?(:mhtml)

          @handlers_registered = true
        end

        # Validate that format is a symbol.
        #
        # @param format [Object] The format to validate
        # @return [void]
        # @raise [ArgumentError] if format is not a symbol
        def validate_format(format)
          raise ArgumentError, 'Format must be a Symbol' unless format.is_a?(Symbol)
        end

        # Validate that handler_class inherits from BaseHandler.
        #
        # @param handler_class [Object] The handler class to validate
        # @return [void]
        # @raise [ArgumentError] if handler_class is invalid
        def validate_handler_class(handler_class)
          raise ArgumentError, 'Handler must be a Class' unless handler_class.is_a?(Class)

          return if handler_class.ancestors.include?(BaseHandler)

          raise ArgumentError,
                'Handler class must inherit from Uniword::Formats::BaseHandler'
        end
      end
    end
  end
end
