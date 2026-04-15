# frozen_string_literal: true

require "pathname"
# LinkChecker autoloaded via lib/uniword/validation.rb

module Uniword
  module Validation
    module Checkers
      # Validates file reference links.
      #
      # Responsibility: Validate referenced files exist on filesystem.
      # Single Responsibility: File reference validation only.
      #
      # Verifies:
      # - Referenced files exist
      # - File paths are valid
      # - Relative and absolute paths (configurable)
      #
      # Configuration options:
      # - base_path: Base directory for relative paths
      # - check_relative_paths: Whether to check relative file paths
      # - check_absolute_paths: Whether to check absolute file paths
      #
      # @example Create and use checker
      #   checker = FileReferenceChecker.new(config: {
      #     base_path: '/documents'
      #   })
      #   result = checker.check(file_link, document)
      class FileReferenceChecker < LinkChecker
        # Default configuration values
        DEFAULTS = {
          base_path: ".",
          check_relative_paths: true,
          check_absolute_paths: true
        }.freeze

        # Check if this checker can validate the given link.
        #
        # @param link [Object] The link to check
        # @return [Boolean] true if link is a file reference
        #
        # @example
        #   checker.can_check?(file_link) # => true
        def can_check?(link)
          return false unless enabled?

          # Check if link is a file path (string or has path attribute)
          if link.is_a?(String)
            looks_like_file_path?(link)
          elsif link.respond_to?(:url)
            url = link.url
            url && looks_like_file_path?(url)
          elsif link.respond_to?(:path)
            true
          else
            false
          end
        end

        # Validate the file reference.
        #
        # @param link [Object] The link to validate
        # @param document [Object] The document (used for context)
        # @return [ValidationResult] The validation result
        #
        # @example
        #   result = checker.check(file_link)
        def check(link, document = nil)
          return ValidationResult.unknown(link, "Checker disabled") unless enabled?

          file_path = extract_file_path(link)
          return ValidationResult.failure(link, "No file path specified") unless file_path

          # Resolve the file path
          resolved_path = resolve_path(file_path, document)

          # Check if path type is enabled
          if resolved_path.absolute?
            unless config_value(:check_absolute_paths, DEFAULTS[:check_absolute_paths])
              return ValidationResult.warning(
                link,
                "Absolute path checking disabled"
              )
            end
          else
            unless config_value(:check_relative_paths, DEFAULTS[:check_relative_paths])
              return ValidationResult.warning(
                link,
                "Relative path checking disabled"
              )
            end
          end

          # Check if file exists
          if File.exist?(resolved_path)
            metadata = {
              path: file_path,
              resolved_path: resolved_path.to_s,
              type: File.directory?(resolved_path) ? "directory" : "file"
            }

            ValidationResult.success(link, metadata: metadata)
          else
            ValidationResult.failure(
              link,
              "File not found: #{file_path}",
              metadata: {
                path: file_path,
                resolved_path: resolved_path.to_s
              }
            )
          end
        rescue StandardError => e
          ValidationResult.failure(
            link,
            "Error checking file: #{e.message}",
            metadata: { error: e.class.name }
          )
        end

        private

        # Extract file path from link object.
        #
        # @param link [Object] The link object
        # @return [String, nil] File path
        def extract_file_path(link)
          if link.is_a?(String)
            link
          elsif link.respond_to?(:path)
            link.path
          elsif link.respond_to?(:url)
            url = link.url
            # Extract file path from file:// URLs
            if url&.start_with?("file://")
              url.sub(%r{^file://}, "")
            else
              url
            end
          end
        end

        # Resolve file path (handle relative paths).
        #
        # @param file_path [String] The file path
        # @param document [Object] The document (for context)
        # @return [Pathname] Resolved path
        def resolve_path(file_path, document)
          path = Pathname.new(file_path)

          # If already absolute, return as-is
          return path if path.absolute?

          # Resolve relative path
          base_path = determine_base_path(document)
          Pathname.new(base_path).join(path)
        end

        # Determine base path for resolution.
        #
        # @param document [Object] The document
        # @return [String] Base path
        def determine_base_path(document)
          # Try to get document's directory
          if document.respond_to?(:file_path)
            File.dirname(document.file_path)
          else
            # Use configured base path
            config_value(:base_path, DEFAULTS[:base_path])
          end
        end

        # Check if string looks like a file path.
        #
        # @param str [String] The string to check
        # @return [Boolean] true if looks like file path
        def looks_like_file_path?(str)
          return false unless str.is_a?(String)
          return false if str.empty?

          # Check for file:// protocol
          return true if str.start_with?("file://")

          # Check for common file extensions or path separators
          has_extension = str.match?(/\.\w{1,10}$/)
          has_path_separator = str.include?("/") || str.include?("\\")

          # Avoid HTTP(S) URLs
          return false if str.match?(%r{^https?://})

          has_extension || has_path_separator
        end
      end
    end
  end
end
