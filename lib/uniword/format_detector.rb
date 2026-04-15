# frozen_string_literal: true

module Uniword
  # Detects document format from file signatures and extensions.
  #
  # Responsibility: Identify document format using file magic numbers
  # and fallback to extension-based detection. Follows Single Responsibility
  # Principle - detection logic separated from other concerns.
  #
  # Detection strategy:
  # 1. Check file signature (magic number)
  # 2. Check MIME headers for MHTML
  # 3. Fallback to file extension
  #
  # @example Detect format
  #   detector = Uniword::FormatDetector.new
  #   format = detector.detect("document.docx")
  #   # => :docx
  class FormatDetector
    # ZIP file magic number (PK\x03\x04)
    ZIP_SIGNATURE = [0x50, 0x4B, 0x03, 0x04].pack("C*").freeze

    # MIME version header for MHTML
    MIME_HEADER = "MIME-Version:"

    # Detect the format of a file or stream.
    #
    # @param path [String, IO, StringIO] The file path or stream
    # @return [Symbol] The detected format (:docx, :mhtml)
    # @raise [ArgumentError] if path is invalid
    # @raise [ArgumentError] if format cannot be detected
    #
    # @example Detect DOCX
    #   detector = FormatDetector.new
    #   format = detector.detect("document.docx")
    #   # => :docx
    def detect(path)
      # For streams, detect from content
      return detect_stream_format(path) if path.is_a?(IO) || path.is_a?(StringIO)

      validate_path(path)

      # Try signature-based detection first
      format = detect_by_signature(path)
      return format if format

      # Fallback to extension-based detection
      detect_by_extension(path)
    end

    private

    # Validate file path.
    #
    # @param path [String, IO, StringIO] The path or stream to validate
    # @return [void]
    # @raise [ArgumentError] if path is invalid
    def validate_path(path)
      raise ArgumentError, "Path cannot be nil" if path.nil?

      # Allow IO and StringIO objects
      return if path.is_a?(IO) || path.is_a?(StringIO)

      # For strings, validate as file path
      raise ArgumentError, "Path cannot be empty" if path.respond_to?(:empty?) && path.empty?
      raise ArgumentError, "File not found: #{path}" unless File.exist?(path)
      raise ArgumentError, "Path is a directory: #{path}" if File.directory?(path)
    end

    # Detect format from stream content
    #
    # @param stream [IO, StringIO] The stream
    # @return [Symbol] The detected format
    def detect_stream_format(stream)
      # Read header bytes
      original_pos = stream.pos
      header = stream.read(512)
      stream.seek(original_pos) # Reset position

      return nil if header.nil? || header.empty?

      # Check for ZIP signature (DOCX)
      return :docx if header.start_with?(ZIP_SIGNATURE)

      # Check for MIME header (MHTML)
      return :mhtml if header.include?(MIME_HEADER)

      # Default to DOCX for unknown streams
      :docx
    end

    # Detect format by file signature (magic number).
    #
    # @param path [String] The file path
    # @return [Symbol, nil] The detected format or nil if unknown
    def detect_by_signature(path)
      # Read first few bytes for signature check
      header = File.open(path, "rb") { |f| f.read(512) }
      return nil if header.nil? || header.empty?

      # Check for ZIP signature (DOCX)
      return :docx if header.start_with?(ZIP_SIGNATURE)

      # Check for MIME header (MHTML)
      return :mhtml if header.include?(MIME_HEADER)

      nil
    end

    # Detect format by file extension.
    #
    # @param path [String] The file path
    # @return [Symbol] The detected format
    # @raise [ArgumentError] if extension is not recognized
    def detect_by_extension(path)
      extension = File.extname(path).downcase

      case extension
      when ".docx"
        :docx
      when ".docm"
        :docm
      when ".dotx"
        :dotx
      when ".dotm"
        :dotm
      when ".thmx"
        :thmx
      when ".mhtml", ".mht"
        :mhtml
      when ".doc"
        raise ArgumentError,
              "Old Word format (.doc) is not supported. Please convert to .docx first. " \
              "Uniword supports: .docx, .docm, .dotx, .dotm, .mhtml, .mht"
      else
        raise ArgumentError,
              "Unsupported file extension: #{extension}. " \
              "Supported extensions: .docx, .docm, .dotx, .dotm, .thmx, .mhtml, .mht"
      end
    end
  end
end
