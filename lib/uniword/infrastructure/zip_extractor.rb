# frozen_string_literal: true

require "zip"

module Uniword
  module Infrastructure
    # Extracts content from ZIP archives (e.g., DOCX files).
    #
    # Responsibility: Handle ZIP file extraction operations.
    # Does NOT handle: Document parsing or deserialization.
    #
    # DOCX files are ZIP archives containing XML files and media.
    # This class provides low-level ZIP extraction functionality.
    #
    # @example Extract content from a DOCX file
    #   extractor = Uniword::Infrastructure::ZipExtractor.new
    #   content = extractor.extract("document.docx")
    #   xml = content["word/document.xml"]
    class ZipExtractor
      # Extract all files from a ZIP archive or stream.
      #
      # @param path [String, IO, StringIO] The path to the ZIP file or stream
      # @return [Hash<String, String>] Hash mapping file paths to contents
      # @raise [ArgumentError] if path is invalid
      # @raise [Zip::Error] if ZIP extraction fails
      def extract(path)
        # Handle streams directly
        return extract_from_stream(path) if path.is_a?(IO) || path.is_a?(StringIO)

        validate_path(path)

        content = {}

        Zip::File.open(path) do |zip_file|
          zip_file.each do |entry|
            next if entry.directory?

            content[entry.name] = entry.get_input_stream.read.force_encoding("UTF-8")
          end

          # Explicitly extract theme if present
          theme_entry = zip_file.find_entry("word/theme/theme1.xml")
          if theme_entry && !content.key?("word/theme/theme1.xml")
            content["word/theme/theme1.xml"] =
              theme_entry.get_input_stream.read.force_encoding("UTF-8")
          end
        end

        content
      end

      # Extract from IO or StringIO stream
      #
      # @param stream [IO, StringIO] The stream to extract from
      # @return [Hash<String, String>] Hash mapping file paths to contents
      def extract_from_stream(stream)
        content = {}

        Zip::File.open_buffer(stream) do |zip_file|
          zip_file.each do |entry|
            next if entry.directory?

            content[entry.name] = entry.get_input_stream.read.force_encoding("UTF-8")
          end

          # Explicitly extract theme if present
          theme_entry = zip_file.find_entry("word/theme/theme1.xml")
          if theme_entry && !content.key?("word/theme/theme1.xml")
            content["word/theme/theme1.xml"] =
              theme_entry.get_input_stream.read.force_encoding("UTF-8")
          end
        end

        content
      end

      # Extract a specific file from a ZIP archive.
      #
      # @param path [String] The path to the ZIP file
      # @param entry_path [String] The path of the file within the ZIP
      # @return [String, nil] The file content, or nil if not found
      # @raise [ArgumentError] if path is invalid
      def extract_file(path, entry_path)
        validate_path(path)

        Zip::File.open(path) do |zip_file|
          entry = zip_file.find_entry(entry_path)
          return nil unless entry

          entry.get_input_stream.read.force_encoding("UTF-8")
        end
      end

      # List all files in a ZIP archive.
      #
      # @param path [String] The path to the ZIP file
      # @return [Array<String>] Array of file paths within the ZIP
      # @raise [ArgumentError] if path is invalid
      def list_files(path)
        validate_path(path)

        files = []

        Zip::File.open(path) do |zip_file|
          zip_file.each do |entry|
            files << entry.name unless entry.directory?
          end
        end

        files
      end

      private

      # Validate the file path.
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
    end
  end
end
