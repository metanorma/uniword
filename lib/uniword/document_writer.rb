# frozen_string_literal: true

module Uniword
  # Writer for saving Document instances to files.
  #
  # Responsibility: Handle document persistence operations.
  # Follows Single Responsibility Principle - writing logic separated from
  # Document class itself.
  #
  # @example Save document
  #   writer = Uniword::DocumentWriter.new(document)
  #   writer.save("output.docx")
  #
  # @example Save with specific format
  #   writer.save("output.mhtml", format: :mhtml)
  class DocumentWriter
    # @return [Wordprocessingml::DocumentRoot] The document to write
    attr_reader :document

    # Initialize a new DocumentWriter.
    #
    # @param document [Wordprocessingml::DocumentRoot] The document to write
    # @raise [ArgumentError] if document is invalid
    #
    # @example Create writer
    #   writer = DocumentWriter.new(document)
    def initialize(document)
      validate_document(document)
      @document = document
    end

    # Save the document to a file.
    #
    # @param path [String] The output file path
    # @param format [Symbol] The format (:auto, :docx, :mhtml)
    # @return [void]
    # @raise [ArgumentError] if path is invalid
    # @raise [ArgumentError] if format is not supported
    #
    # @example Save as DOCX
    #   writer.save("output.docx")
    #
    # @example Save with explicit format
    #   writer.save("output.mht", format: :mhtml)
    def save(path, format: :auto)
      validate_path(path)

      format = infer_format(path) if format == :auto

      case format
      when :docx
        Ooxml::DocxPackage.to_file(document, path)
      when :dotx, :dotm
        Ooxml::DotxPackage.to_file(document, path)
      when :mhtml
        Mhtml::MhtmlPackage.to_file(document, path)
      else
        raise ArgumentError, "No handler registered for format: #{format.inspect}"
      end
    end

    # Infer the format from file extension.
    #
    # @param path [String] The file path
    # @return [Symbol] The inferred format (:docx, :mhtml)
    # @raise [ArgumentError] if format cannot be inferred
    #
    # @example Infer format
    #   format = writer.infer_format("output.docx")
    #   # => :docx
    def infer_format(path)
      extension = File.extname(path).downcase

      case extension
      when '.docx'
        :docx
      when '.dotx'
        :dotx
      when '.dotm'
        :dotm
      when '.doc', '.mhtml', '.mht'
        :mhtml
      else
        raise ArgumentError,
              "Cannot infer format from extension: #{extension}. " \
              'Supported extensions: .docx, .dotx, .dotm, .doc, .mhtml, .mht'
      end
    end

    # Write the document to a stream (StringIO).
    # Compatible with docx gem API
    #
    # @param stream [IO, StringIO] The output stream
    # @param format [Symbol] The format (:docx, :mhtml)
    # @return [void]
    #
    # @example Write to StringIO
    #   io = StringIO.new
    #   writer.write_to_stream(io)
    #   io.rewind
    #   content = io.read
    def write_to_stream(stream, format: :docx)
      require 'tempfile'

      # Use a temporary file to generate the document
      temp_file = Tempfile.new(['uniword_stream', ".#{format}"], binmode: true)
      begin
        # Save to temp file
        save(temp_file.path, format: format)

        # Read and write to stream in binary mode
        temp_file.rewind
        content = File.binread(temp_file.path)
        stream.write(content)
      ensure
        temp_file.close
        temp_file.unlink
      end
    end

    private

    # Validate the document.
    #
    # Accepts both the aliased Document class and the full Generated class.
    #
    # @param doc [Object] The document to validate
    # @return [void]
    # @raise [ArgumentError] if document is invalid
    def validate_document(doc)
      raise ArgumentError, 'Document cannot be nil' if doc.nil?

      # Accept OOXML Document
      return if doc.is_a?(Uniword::Wordprocessingml::DocumentRoot)
      # Accept MHTML Document
      return if doc.is_a?(Uniword::Mhtml::Document)

      raise ArgumentError, 'Must be a Document instance'
    end

    # Validate the output path.
    #
    # @param path [String] The path to validate
    # @return [void]
    # @raise [ArgumentError] if path is invalid
    def validate_path(path)
      raise ArgumentError, 'Path cannot be nil' if path.nil?
      raise ArgumentError, 'Path cannot be empty' if path.empty?
    end
  end
end
