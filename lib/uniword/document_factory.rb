# frozen_string_literal: true

# All classes autoloaded via lib/uniword.rb
# No require_relative needed - autoload handles lazy loading

module Uniword
  # Factory for creating Document instances.
  #
  # Responsibility: Handle document creation from various sources.
  # Follows Single Responsibility Principle - creation logic separated from
  # Document class itself.
  #
  # @example Create document from file
  #   document = Uniword::DocumentFactory.from_file("document.docx")
  #
  # @example Create empty document
  #   document = Uniword::DocumentFactory.create
  #
  # @example Create with specific format
  #   document = Uniword::DocumentFactory.from_file("doc.mhtml", format: :mhtml)
  class DocumentFactory
    class << self
      # Create a new empty document.
      #
      # @return [Document] A new empty document
      #
      # @example Create empty document
      #   document = DocumentFactory.create
      def create
        Document.new
      end

      # Create a document from a file.
      #
      # @param path [String] The file path
      # @param format [Symbol] The format (:auto, :docx, :mhtml)
      # @return [Document] The loaded document
      # @raise [ArgumentError] if path is invalid
      # @raise [ArgumentError] if format is not supported
      #
      # @example Load DOCX file
      #   document = DocumentFactory.from_file("document.docx")
      #
      # @example Load with explicit format
      #   document = DocumentFactory.from_file("doc.mht", format: :mhtml)
      def from_file(path, format: :auto)
        # Handle binary strings (for docx gem compatibility)
        # Convert to StringIO if it's a binary string (contains null bytes or has binary encoding)
        if path.is_a?(String) && (path.encoding == Encoding::ASCII_8BIT || path.include?("\x00"))
          path = StringIO.new(path)
        end

        validate_path(path)

        format = detect_format(path) if format == :auto

        case format
        when :docx
          Ooxml::DocxPackage.from_file(path)
        when :dotx, :dotm
          Ooxml::DotxPackage.from_file(path)
        when :mhtml
          Mhtml::MhtmlPackage.from_file(path)
        else
          raise ArgumentError, "Unsupported format: #{format}"
        end
      rescue ArgumentError
        # Re-raise validation errors as-is
        raise
      rescue Zip::Error => e
        raise CorruptedFileError.new(path.to_s, "Invalid ZIP structure: #{e.message}")
      rescue Nokogiri::XML::SyntaxError => e
        raise CorruptedFileError.new(path.to_s, "Invalid XML: #{e.message}")
      rescue StandardError => e
        # Re-raise our custom errors
        raise if e.is_a?(Uniword::Error)

        # Wrap other errors
        raise CorruptedFileError.new(path.to_s, e.message)
      end

      # Create a document from binary data (IO/StringIO stream or binary string).
      # Compatible with docx gem API
      #
      # @param stream [IO, StringIO, String] The binary stream or data
      # @param format [Symbol] The format (:auto, :docx, :mhtml)
      # @return [Document] The loaded document (Generated::Wordprocessingml::DocumentRoot)
      #
      # @example Load from stream
      #   stream = StringIO.new(File.binread("doc.docx"))
      #   document = DocumentFactory.from_file_data(stream)
      #
      # @example Load from binary string
      #   data = File.binread("doc.docx")
      #   document = DocumentFactory.from_file_data(data)
      def from_file_data(stream, format: :auto)
        # Convert binary string to StringIO if needed
        stream = StringIO.new(stream) if stream.is_a?(String)

        # Use from_file which already supports IO/StringIO
        from_file(stream, format: format)
      end

      # Create a Theme from a theme file (.thmx).
      #
      # IMPORTANT: This returns a Theme object, NOT a Document!
      # Theme files (.thmx) are standalone packages containing only theme data.
      #
      # @param path [String] The file path to .thmx file
      # @param format [Symbol] The format (:auto, :thmx)
      # @return [Theme] The loaded theme
      # @raise [ArgumentError] if path is invalid or not a theme format
      #
      # @example Load theme file
      #   theme = DocumentFactory.from_theme_file("celestial.thmx")
      #   theme.name # => "Celestial"
      def from_theme_file(path, format: :auto)
        validate_path(path)

        format = detect_format(path) if format == :auto

        case format
        when :thmx
          Ooxml::ThmxPackage.from_file(path)
        else
          raise ArgumentError, "Not a theme format: #{format}. Use from_file() for documents."
        end
      rescue ArgumentError
        # Re-raise validation errors as-is
        raise
      rescue Zip::Error => e
        raise CorruptedFileError.new(path.to_s, "Invalid ZIP structure: #{e.message}")
      rescue Nokogiri::XML::SyntaxError => e
        raise CorruptedFileError.new(path.to_s, "Invalid XML: #{e.message}")
      rescue StandardError => e
        # Re-raise our custom errors
        raise if e.is_a?(Uniword::Error)

        # Wrap other errors
        raise CorruptedFileError.new(path.to_s, e.message)
      end

      # Detect the format of a file.
      #
      # Uses FormatDetector for signature-based detection with extension fallback.
      #
      # @param path [String] The file path
      # @return [Symbol] The detected format (:docx, :mhtml)
      # @raise [ArgumentError] if format cannot be detected
      #
      # @example Detect format
      #   format = DocumentFactory.detect_format("document.docx")
      #   # => :docx
      def detect_format(path)
        detector = FormatDetector.new
        detector.detect(path)
      end

      private

      # Validate file path or stream.
      #
      # @param path [String, IO, StringIO] The path or stream to validate
      # @return [void]
      # @raise [FileNotFoundError] if file doesn't exist
      # @raise [ArgumentError] if path is nil or empty
      def validate_path(path)
        raise ArgumentError, 'Path cannot be nil' if path.nil?

        # Allow IO and StringIO objects (for docx gem compatibility)
        return if path.is_a?(IO) || path.is_a?(StringIO)

        # For strings, validate
        raise ArgumentError, 'Path cannot be empty' if path.respond_to?(:empty?) && path.empty?
        raise FileNotFoundError, path unless File.exist?(path)
      end
    end
  end
end
