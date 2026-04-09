# frozen_string_literal: true

require 'zip'
require 'fileutils'

module Uniword
  module Infrastructure
    # Packages content into ZIP archives (e.g., DOCX files).
    #
    # Responsibility: Handle ZIP file creation and packaging operations.
    # Does NOT handle: Document serialization or format-specific logic.
    #
    # DOCX files are ZIP archives containing XML files and media.
    # This class provides low-level ZIP packaging functionality.
    #
    # @example Package content into a DOCX file
    #   packager = Uniword::Infrastructure::ZipPackager.new
    #   content = {
    #     "word/document.xml" => xml_content,
    #     "[Content_Types].xml" => types_content
    #   }
    #   packager.package(content, "output.docx")
    class ZipPackager
      # Package content into a ZIP file.
      #
      # @param content [Hash<String, String>] Hash mapping file paths to contents
      # @param output_path [String] The path for the output ZIP file
      # @return [void]
      # @raise [ArgumentError] if arguments are invalid
      def package(content, output_path)
        validate_content(content)
        validate_output_path(output_path)

        # Ensure output directory exists
        FileUtils.mkdir_p(File.dirname(output_path))

        # Create ZIP file
        Zip::File.open(output_path, Zip::File::CREATE) do |zip_file|
          content.each do |entry_path, entry_content|
            zip_file.get_output_stream(entry_path) do |stream|
              # Binary data (ASCII-8BIT) is written as-is;
              # text content is ensured to be UTF-8
              final_content =
                if entry_content.encoding == Encoding::ASCII_8BIT
                  entry_content
                else
                  entry_content.encode(
                    'UTF-8', invalid: :replace, undef: :replace
                  )
                end
              stream.write(final_content)
            end
          end
        end
      end

      # Add a file to an existing ZIP archive.
      #
      # @param zip_path [String] The path to the ZIP file
      # @param entry_path [String] The path for the file within the ZIP
      # @param entry_content [String] The content to add
      # @return [void]
      # @raise [ArgumentError] if arguments are invalid
      def add_file(zip_path, entry_path, entry_content)
        validate_zip_path(zip_path)
        raise ArgumentError, 'Entry path cannot be nil' if entry_path.nil?
        raise ArgumentError, 'Entry path cannot be empty' if entry_path.empty?

        Zip::File.open(zip_path, Zip::File::CREATE) do |zip_file|
          zip_file.get_output_stream(entry_path) do |stream|
            stream.write(entry_content)
          end
        end
      end

      # Remove a file from a ZIP archive.
      #
      # @param zip_path [String] The path to the ZIP file
      # @param entry_path [String] The path of the file to remove
      # @return [Boolean] true if file was removed, false if not found
      # @raise [ArgumentError] if arguments are invalid
      def remove_file(zip_path, entry_path)
        validate_zip_path(zip_path)

        Zip::File.open(zip_path) do |zip_file|
          entry = zip_file.find_entry(entry_path)
          return false unless entry

          zip_file.remove(entry_path)
          true
        end
      end

      private

      # Validate the content hash.
      #
      # @param content [Object] The content to validate
      # @return [void]
      # @raise [ArgumentError] if content is invalid
      def validate_content(content)
        raise ArgumentError, 'Content cannot be nil' if content.nil?
        raise ArgumentError, 'Content must be a Hash' unless content.is_a?(Hash)
        raise ArgumentError, 'Content cannot be empty' if content.empty?

        content.each do |path, data|
          raise ArgumentError, 'Entry path cannot be nil' if path.nil?
          raise ArgumentError, 'Entry path cannot be empty' if path.empty?
          raise ArgumentError, "Entry content cannot be nil for #{path}" if data.nil?
        end
      end

      # Validate the output path.
      #
      # @param path [String] The path to validate
      # @return [void]
      # @raise [ArgumentError] if path is invalid
      def validate_output_path(path)
        raise ArgumentError, 'Output path cannot be nil' if path.nil?
        raise ArgumentError, 'Output path cannot be empty' if path.empty?

        dir = File.dirname(path)
        return unless File.exist?(dir)
        return if File.directory?(dir)

        raise ArgumentError, "Parent path is not a directory: #{dir}"
      end

      # Validate the ZIP path for modification operations.
      #
      # @param path [String] The path to validate
      # @return [void]
      # @raise [ArgumentError] if path is invalid
      def validate_zip_path(path)
        raise ArgumentError, 'ZIP path cannot be nil' if path.nil?
        raise ArgumentError, 'ZIP path cannot be empty' if path.empty?
      end
    end
  end
end
