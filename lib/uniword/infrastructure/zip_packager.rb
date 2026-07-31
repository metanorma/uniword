# frozen_string_literal: true

require "zip"
require "fileutils"

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
      #
      # @note On Windows, Zip::File::CREATE mode fails when target exists
      # because Rubyzip tries to atomically rename a temp file over it.
      # We use a temp file approach to avoid this issue.
      def package(content, output_path)
        validate_content(content)
        validate_output_path(output_path)

        # Ensure output directory exists
        FileUtils.mkdir_p(File.dirname(output_path))

        # Use Zip::OutputStream directly (not Zip::File) so that Entry objects
        # with internal_file_attributes=0 are preserved through serialization.
        # Zip::File wraps entries in StreamableStream which is NOT kind_of?(Entry),
        # causing put_next_entry to discard our Entry and create a fresh one.
        temp_path = "#{output_path}.#{Process.pid}.tmp"

        ordered_content = order_content(content)
        fixed_time = deterministic_timestamp

        was_zip64 = Zip.write_zip64_support
        Zip.write_zip64_support = false
        begin
          Zip::OutputStream.open(temp_path) do |zos|
            ordered_content.each do |entry_path, entry_content|
              entry = Zip::Entry.new(temp_path, entry_path.to_s)
              entry.internal_file_attributes = 0
              entry.external_file_attributes = 0
              entry.fstype = Zip::FSTYPE_FAT
              entry.time = fixed_time if fixed_time

              zos.put_next_entry(entry)

              final_content =
                if entry_content.encoding == Encoding::ASCII_8BIT
                  entry_content
                else
                  entry_content.encode(
                    "UTF-8", invalid: :replace, undef: :replace
                  )
                end
              zos.write(final_content)
            end
          end
        ensure
          Zip.write_zip64_support = was_zip64
        end

        move_temp_to_output(temp_path, output_path)
      ensure
        remove_temp_file(temp_path)
      end

      private

      # When `Uniword.configuration.deterministic_output` is true,
      # reorder entries (priority for OPC-required first, alphabetical
      # for the rest). Otherwise return content unchanged (insertion
      # order, which matches Word's behavior).
      #
      # @param content [Hash<String, String>]
      # @return [Hash<String, String>] ordered hash
      def order_content(content)
        return content unless Uniword.configuration.deterministic_output

        ordered_keys = Docx::DeterministicOutput.reorder_entries(content.keys)
        ordered_keys.to_h { |k| [k, content[k]] }
      end

      # Fixed timestamp for deterministic mode; nil otherwise.
      #
      # @return [Time, nil]
      def deterministic_timestamp
        return nil unless Uniword.configuration.deterministic_output

        Docx::DeterministicOutput::FIXED_TIMESTAMP
      end

      # Add a file to an existing ZIP archive.
      #
      # @param zip_path [String] The path to the ZIP file
      # @param entry_path [String] The path for the file within the ZIP
      # @param entry_content [String] The content to add
      # @return [void]
      # @raise [ArgumentError] if arguments are invalid
      #
      # @note On Windows, we must close the original ZIP handle before
      # attempting to overwrite it. We extract content first, then close
      # the handle, then package to a temp file and move.
      def add_file(zip_path, entry_path, entry_content)
        validate_zip_path(zip_path)
        raise ArgumentError, "Entry path cannot be nil" if entry_path.nil?
        raise ArgumentError, "Entry path cannot be empty" if entry_path.empty?

        # Extract existing content into a local variable
        content = {}
        Zip::File.open(zip_path) do |zip_file|
          zip_file.each do |entry|
            next if entry.directory?

            content[entry.name] = entry.get_input_stream.read
          end
        end
        # Handle is now fully closed before we modify the file

        # Add new entry and write to a temp file first, then move
        content[entry_path] = entry_content
        write_to_zip_file(content, zip_path)
      end

      # Remove a file from a ZIP archive.
      #
      # @param zip_path [String] The path to the ZIP file
      # @param entry_path [String] The path of the file to remove
      # @return [Boolean] true if file was removed, false if not found
      # @raise [ArgumentError] if arguments are invalid
      #
      # @note On Windows, we must close the original ZIP handle before
      # attempting to overwrite it. We extract content first, then close
      # the handle, then write to a temp file and move.
      def remove_file(zip_path, entry_path)
        validate_zip_path(zip_path)

        # Extract existing content into a local variable
        content = {}
        found = false
        Zip::File.open(zip_path) do |zip_file|
          zip_file.each do |entry|
            next if entry.directory?

            if entry.name == entry_path
              found = true
            else
              content[entry.name] = entry.get_input_stream.read
            end
          end
        end
        # Handle is now fully closed before we modify the file

        return false unless found

        write_to_zip_file(content, zip_path)
        true
      end

      private

      # Write content to a ZIP file using a temp file and atomic move.
      # This avoids Windows file locking issues by ensuring we never
      # write directly to the target file while it might be open.
      #
      # @param content [Hash<String, String>] Hash mapping file paths to contents
      # @param output_path [String] The path for the output ZIP file
      # @return [void]
      def write_to_zip_file(content, output_path)
        temp_path = "#{output_path}.#{Process.pid}.#{rand(1000)}.tmp"

        was_zip64 = Zip.write_zip64_support
        Zip.write_zip64_support = false
        begin
          Zip::OutputStream.open(temp_path) do |zos|
            content.each do |entry_path, entry_content|
              entry = Zip::Entry.new(temp_path, entry_path.to_s)
              entry.internal_file_attributes = 0
              entry.external_file_attributes = 0
              entry.fstype = Zip::FSTYPE_FAT

              zos.put_next_entry(entry)

              final_content =
                if entry_content.encoding == Encoding::ASCII_8BIT
                  entry_content
                else
                  entry_content.encode(
                    "UTF-8", invalid: :replace, undef: :replace
                  )
                end
              zos.write(final_content)
            end
          end
        ensure
          Zip.write_zip64_support = was_zip64
        end

        move_temp_to_output(temp_path, output_path)
      ensure
        remove_temp_file(temp_path)
      end

      def move_temp_to_output(temp_path, output_path)
        retries = 10
        begin
          FileUtils.rm_f(output_path)
          sleep(0.5)
          File.binwrite(output_path, File.binread(temp_path))
          FileUtils.rm_f(temp_path)
        rescue Errno::EACCES
          retries -= 1
          raise unless retries.positive?

          sleep(0.5)
          retry
        end
      end

      # Best-effort temp file removal with Windows-safe retries. AV
      # scanners and the indexer briefly hold newly-written files; a
      # single `FileUtils.rm_f` can return EACCES and leak the temp.
      def remove_temp_file(temp_path)
        return unless defined?(temp_path) && temp_path
        return unless File.exist?(temp_path)

        retries = 5
        begin
          FileUtils.rm_f(temp_path)
        rescue Errno::EACCES
          retries -= 1
          if retries.positive?
            sleep(0.3)
            retry
          end
        end
      end

      # Validate the content hash.
      #
      # @param content [Object] The content to validate
      # @return [void]
      # @raise [ArgumentError] if content is invalid
      def validate_content(content)
        raise ArgumentError, "Content cannot be nil" if content.nil?
        raise ArgumentError, "Content must be a Hash" unless content.is_a?(Hash)
        raise ArgumentError, "Content cannot be empty" if content.empty?

        content.each do |path, data|
          raise ArgumentError, "Entry path cannot be nil" if path.nil?
          raise ArgumentError, "Entry path cannot be empty" if path.empty?
          if data.nil?
            raise ArgumentError,
                  "Entry content cannot be nil for #{path}"
          end
        end
      end

      # Validate the output path.
      #
      # @param path [String] The path to validate
      # @return [void]
      # @raise [ArgumentError] if path is invalid
      def validate_output_path(path)
        raise ArgumentError, "Output path cannot be nil" if path.nil?
        raise ArgumentError, "Output path cannot be empty" if path.empty?

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
        raise ArgumentError, "ZIP path cannot be nil" if path.nil?
        raise ArgumentError, "ZIP path cannot be empty" if path.empty?
      end
    end
  end
end
