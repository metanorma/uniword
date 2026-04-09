# frozen_string_literal: true

require 'zip'
require 'tmpdir'
require 'fileutils'

module Uniword
  module Ooxml
    # Abstract base class for Office Open XML package files
    #
    # Provides common functionality for ZIP-based Office formats:
    # - Extraction to temporary directory
    # - Packaging from temporary directory to ZIP
    # - File reading/writing within extracted package
    # - Cleanup of temporary files
    #
    # Subclasses must implement:
    # - load_content: Parse package contents into domain model
    # - save_content: Serialize domain model into package files
    #
    # @example Create a specialized package
    #   class MyPackage < PackageFile
    #     def load_content
    #       extract
    #       data_xml = read_file('data/main.xml')
    #       @model = MyModel.from_xml(data_xml)
    #     end
    #
    #     def save_content(model)
    #       @model = model
    #       write_file('data/main.xml', model.to_xml)
    #     end
    #   end
    class PackageFile
      # Package file path
      attr_reader :path

      # Temporary extraction directory
      attr_reader :extracted_dir

      # Initialize package
      #
      # @param path [String] Path to package file (.dotx, .thmx, etc.)
      def initialize(path:)
        @path = path
        @extracted_dir = nil
      end

      # Extract package contents to temporary directory
      #
      # Creates a temporary directory and extracts all ZIP contents.
      # The extracted_dir attribute is set to the temp directory path.
      #
      # @return [String] Path to temporary extraction directory
      # @raise [ArgumentError] if file doesn't exist or is invalid
      def extract
        raise ArgumentError, "File not found: #{@path}" unless File.exist?(@path)

        @extracted_dir = Dir.mktmpdir('uniword-package-')

        Zip::File.open(@path) do |zip_file|
          zip_file.each do |entry|
            target_path = File.join(@extracted_dir, entry.name)
            FileUtils.mkdir_p(File.dirname(target_path))
            entry.extract(target_path)
          end
        end

        @extracted_dir
      end

      # Package temporary directory contents into ZIP file
      #
      # Creates a new ZIP file at output_path containing all files
      # from the extracted temporary directory.
      #
      # @param output_path [String] Path for output package file
      # @return [String] Path to created package file
      # @raise [RuntimeError] if extracted_dir is nil (must extract first)
      def package(output_path)
        raise 'Must extract before packaging' unless @extracted_dir

        # Ensure output directory exists
        FileUtils.mkdir_p(File.dirname(output_path))

        Zip::File.open(output_path, Zip::File::CREATE) do |zipfile|
          Dir.glob(File.join(@extracted_dir, '**', '*')).each do |file_path|
            next if File.directory?(file_path)

            # Calculate relative path within package
            relative_path = file_path.sub("#{@extracted_dir}/", '')

            # Skip if entry already exists (prevents duplicates)
            next if zipfile.find_entry(relative_path)

            zipfile.add(relative_path, file_path)
          end
        end

        output_path
      end

      # Clean up temporary extraction directory
      #
      # Removes the temporary directory and all its contents.
      # Safe to call multiple times.
      #
      # @return [void]
      def cleanup
        return unless @extracted_dir

        FileUtils.rm_rf(@extracted_dir)
        @extracted_dir = nil
      end

      # Read file from extracted package
      #
      # @param relative_path [String] Path relative to package root
      # @return [String] File contents
      # @raise [RuntimeError] if extracted_dir is nil (must extract first)
      # @raise [Errno::ENOENT] if file doesn't exist
      def read_file(relative_path)
        raise 'Must extract before reading files' unless @extracted_dir

        full_path = File.join(@extracted_dir, relative_path)
        File.read(full_path)
      end

      # Write file to extracted package
      #
      # Creates parent directories if needed.
      #
      # @param relative_path [String] Path relative to package root
      # @param content [String] File contents to write
      # @return [void]
      # @raise [RuntimeError] if extracted_dir is nil (must extract first)
      def write_file(relative_path, content)
        raise 'Must extract before writing files' unless @extracted_dir

        full_path = File.join(@extracted_dir, relative_path)
        FileUtils.mkdir_p(File.dirname(full_path))
        File.write(full_path, content)
      end

      # Check if file exists in extracted package
      #
      # @param relative_path [String] Path relative to package root
      # @return [Boolean] true if file exists
      def file_exists?(relative_path)
        return false unless @extracted_dir

        full_path = File.join(@extracted_dir, relative_path)
        File.exist?(full_path)
      end

      # Load package content into domain model
      #
      # This is an abstract method that must be implemented by subclasses.
      # Should extract the package and parse its contents into the appropriate
      # domain model object.
      #
      # @return [Object] Domain model object (Theme, StyleSet, etc.)
      # @raise [NotImplementedError] if not overridden
      def load_content
        raise NotImplementedError,
              "#{self.class} must implement load_content"
      end

      # Save domain model content into package
      #
      # This is an abstract method that must be implemented by subclasses.
      # Should serialize the domain model and write necessary files to the
      # extracted directory.
      #
      # @param content [Object] Domain model object to save
      # @return [void]
      # @raise [NotImplementedError] if not overridden
      def save_content(content)
        raise NotImplementedError,
              "#{self.class} must implement save_content(content)"
      end

      # Convenience method: Load from file
      #
      # Extracts package, loads content, and returns the loaded model.
      # Does NOT clean up automatically - caller must call cleanup.
      #
      # @param path [String] Path to package file
      # @return [Object] Loaded domain model
      def self.load_from_file(path)
        package = new(path: path)
        package.load_content
      end

      # Convenience method: Save to file
      #
      # Creates package from model, writes to file, and cleans up.
      #
      # @param model [Object] Domain model to save
      # @param output_path [String] Path for output package file
      # @param template_path [String, nil] Optional template to base package on
      # @return [String] Path to created package file
      def self.save_to_file(model, output_path, template_path: nil)
        # Determine source package
        source = template_path || create_empty_package_path

        package = new(path: source)
        package.extract
        package.save_content(model)
        package.package(output_path)
        package.cleanup

        output_path
      end

      # Create an empty package template
      #
      # Subclasses may override to provide specific empty templates.
      #
      # @return [String] Path to empty package template
      def self.create_empty_package_path
        raise NotImplementedError,
              "#{name} must implement create_empty_package_path or provide template_path"
      end
    end
  end
end
