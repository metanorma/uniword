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
      # @return [Wordprocessingml::DocumentRoot] A new empty document
      #
      # @example Create empty document
      #   document = DocumentFactory.create
      def create
        Wordprocessingml::DocumentRoot.new
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
          package = Ooxml::DocxPackage.from_file(path)
          # Return the document part for convenience, but copy all parts for round-trip
          doc = package.respond_to?(:document) ? package.document : package
          copy_package_parts_to_document(package, doc)
          doc
        when :dotx, :dotm
          package = Ooxml::DotxPackage.from_file(path)
          package.respond_to?(:document) ? package.document : package
        when :mhtml
          package = Mhtml::MhtmlPackage.from_file(path)
          # MhtmlPackage returns a Document, return it directly
          package.respond_to?(:document) ? package.document : package
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

      # Copy package parts to document for round-trip preservation
      #
      # @param package [Ooxml::DocxPackage] The source package
      # @param document [Wordprocessingml::DocumentRoot] The target document
      # @return [void]
      def copy_package_parts_to_document(package, document)
        return unless document.is_a?(Uniword::Wordprocessingml::DocumentRoot)

        document.styles_configuration = package.styles if package.styles
        document.numbering_configuration = package.numbering if package.numbering
        document.settings = package.settings if package.settings
        document.font_table = package.font_table if package.font_table
        document.web_settings = package.web_settings if package.web_settings
        document.theme = package.theme if package.theme
        document.core_properties = package.core_properties if package.core_properties
        document.app_properties = package.app_properties if package.app_properties
        document.document_rels = package.document_rels if package.document_rels
        document.theme_rels = package.theme_rels if package.theme_rels
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
