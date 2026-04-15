# frozen_string_literal: true

# LayerValidator autoloaded via lib/uniword/validation.rb

module Uniword
  module Validation
    module Validators
      # Validates file structure (existence, readability, extension, size).
      #
      # Responsibility: Validate file-level properties.
      # Single Responsibility: Only validates file structure.
      #
      # This is Layer 1 validation - the most basic check that must pass
      # before any other validation can occur.
      #
      # Checks:
      # - File exists
      # - File is readable
      # - File extension is appropriate
      # - File size is reasonable
      #
      # @example Validate a file
      #   validator = FileStructureValidator.new(config)
      #   result = validator.validate('/path/to/document.docx')
      #   puts result.valid? # => true
      class FileStructureValidator < LayerValidator
        def layer_name
          "File Structure"
        end

        def validate(path)
          result = LayerValidationResult.new(layer_name)

          # Check file exists
          return result.add_error("File does not exist", critical: true) unless File.exist?(path)

          # Check readable
          unless File.readable?(path)
            return result.add_error("File is not readable",
                                    critical: true)
          end

          # Check extension
          validate_extension(path, result) if check_extension?

          # Check file size
          validate_size(path, result) if check_size?

          result
        end

        private

        def check_extension?
          layer_config[:check_extension] != false
        end

        def check_size?
          layer_config[:check_size] != false
        end

        def layer_config
          @config[:file_structure] || {}
        end

        def validate_extension(path, result)
          allowed = layer_config[:allowed_extensions] || [".docx", ".doc"]

          return if allowed.any? { |ext| path.end_with?(ext) }

          result.add_warning(
            "Unusual file extension (expected #{allowed.join(" or ")})"
          )
        end

        def validate_size(path, result)
          size = File.size(path)
          max_size = @config[:max_file_size] || 104_857_600 # 100MB default

          if size.zero?
            result.add_error("File is empty", critical: true)
          elsif size > max_size
            result.add_warning(
              "File is very large (#{format_bytes(size)})"
            )
          end
        end

        def format_bytes(bytes)
          if bytes < 1024
            "#{bytes} bytes"
          elsif bytes < 1024 * 1024
            "#{(bytes / 1024.0).round(1)} KB"
          else
            "#{(bytes / (1024.0 * 1024)).round(1)} MB"
          end
        end
      end
    end
  end
end
