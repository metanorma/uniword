# frozen_string_literal: true

module Uniword
  module Formats
    # Abstract base class defining the format handler interface.
    #
    # This class implements the Template Method pattern, defining the algorithm
    # structure for reading and writing documents while allowing subclasses to
    # override specific steps.
    #
    # @abstract Subclass and implement abstract methods to create a format handler
    #
    # @example Creating a custom format handler
    #   class MyFormatHandler < Uniword::Formats::BaseHandler
    #     def extract_content(path)
    #       # Extract content from file
    #     end
    #
    #     def deserialize(content)
    #       # Convert content to Document
    #     end
    #
    #     def serialize(document)
    #       # Convert Document to format-specific content
    #     end
    #
    #     def package_and_save(content, path)
    #       # Save content to file
    #     end
    #   end
    class BaseHandler
      # Error raised when an abstract method is not implemented
      class NotImplementedError < StandardError; end

      # Error raised when file format is invalid
      class InvalidFormatError < StandardError; end

      # Read a document from a file.
      #
      # This is a template method that defines the workflow:
      # 1. Validate the file path exists
      # 2. Extract content from the file
      # 3. Deserialize content into a Document
      #
      # @param path [String] The file path to read from
      # @return [Document] The deserialized document
      # @raise [ArgumentError] if path is invalid
      # @raise [InvalidFormatError] if file format is invalid
      def read(path)
        validate_read_path(path)
        content = extract_content(path)
        deserialize(content)
      end

      # Write a document to a file.
      #
      # This is a template method that defines the workflow:
      # 1. Validate the document is valid
      # 2. Serialize the document to format-specific content
      # 3. Package and save the content to file
      #
      # @param document [Document] The document to write
      # @param path [String] The file path to write to
      # @return [void]
      # @raise [ArgumentError] if document is invalid
      def write(document, path)
        validate_document(document)
        serialized = serialize(document)
        package_and_save(serialized, path)
      end

      # Check if this handler can handle the given file.
      #
      # @param path [String] The file path to check
      # @return [Boolean] true if this handler can handle the file
      def can_handle?(path)
        return false unless File.exist?(path)

        supported_extensions.any? { |ext| path.downcase.end_with?(ext) }
      end

      # Get the supported file extensions for this handler.
      #
      # @return [Array<String>] Array of supported extensions (e.g., ['.docx'])
      def supported_extensions
        []
      end

      protected

      # Extract content from a file.
      #
      # @abstract Subclasses must implement this method
      # @param path [String] The file path to extract from
      # @return [Object] The extracted content (format-specific)
      # @raise [NotImplementedError] if not implemented by subclass
      def extract_content(path)
        raise NotImplementedError,
              "#{self.class} must implement extract_content(path)"
      end

      # Deserialize content into a Document.
      #
      # @abstract Subclasses must implement this method
      # @param content [Object] The content to deserialize
      # @return [Document] The deserialized document
      # @raise [NotImplementedError] if not implemented by subclass
      def deserialize(content)
        raise NotImplementedError,
              "#{self.class} must implement deserialize(content)"
      end

      # Serialize a Document to format-specific content.
      #
      # @abstract Subclasses must implement this method
      # @param document [Document] The document to serialize
      # @return [Object] The serialized content (format-specific)
      # @raise [NotImplementedError] if not implemented by subclass
      def serialize(document)
        raise NotImplementedError,
              "#{self.class} must implement serialize(document)"
      end

      # Package and save content to a file.
      #
      # @abstract Subclasses must implement this method
      # @param content [Object] The content to save
      # @param path [String] The file path to save to
      # @return [void]
      # @raise [NotImplementedError] if not implemented by subclass
      def package_and_save(content, path)
        raise NotImplementedError,
              "#{self.class} must implement package_and_save(content, path)"
      end

      private

      # Validate that the file path exists and is readable.
      #
      # @param path [String, IO, StringIO] The file path or stream to validate
      # @return [void]
      # @raise [ArgumentError] if path is invalid
      def validate_read_path(path)
        raise ArgumentError, 'Path cannot be nil' if path.nil?

        # Allow IO and StringIO objects (for docx gem compatibility)
        return if path.is_a?(IO) || path.is_a?(StringIO)

        # For string paths, validate
        raise ArgumentError, 'Path cannot be empty' if path.respond_to?(:empty?) && path.empty?
        raise ArgumentError, "File not found: #{path}" unless File.exist?(path)
        raise ArgumentError, "Path is a directory: #{path}" if File.directory?(path)
        raise ArgumentError, "File not readable: #{path}" unless File.readable?(path)
      end

      # Validate that the document is a valid Document instance.
      #
      # @param document [Document, Generated::Wordprocessingml::DocumentRoot] The document to validate
      # @return [void]
      # @raise [ArgumentError] if document is invalid
      def validate_document(document)
        raise ArgumentError, 'Document cannot be nil' if document.nil?

        # Accept both the alias and the generated class
        return if document.is_a?(Document)
        return if document.is_a?(Generated::Wordprocessingml::DocumentRoot)

        raise ArgumentError, "Not a Document instance, got #{document.class}"
      end

      # Validate that the output path is writable.
      #
      # @param path [String] The file path to validate
      # @return [void]
      # @raise [ArgumentError] if path is invalid
      def validate_write_path(path)
        raise ArgumentError, 'Path cannot be nil' if path.nil?
        raise ArgumentError, 'Path cannot be empty' if path.empty?

        dir = File.dirname(path)
        raise ArgumentError, "Directory not found: #{dir}" unless File.directory?(dir)
        raise ArgumentError, "Directory not writable: #{dir}" unless File.writable?(dir)
      end
    end
  end
end
