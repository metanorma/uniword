# frozen_string_literal: true

require 'zip'
require_relative '../layer_validator'

module Uniword
  module Validation
    module Validators
      # Validates ZIP archive integrity.
      #
      # Responsibility: Validate ZIP structure and contents.
      # Single Responsibility: Only validates ZIP integrity.
      #
      # This is Layer 2 validation - validates the ZIP container that
      # holds all OOXML parts.
      #
      # Checks:
      # - File opens as valid ZIP
      # - ZIP is not empty
      # - Required entries exist
      # - Entries are not corrupted
      #
      # @example Validate ZIP integrity
      #   validator = ZipIntegrityValidator.new(config)
      #   result = validator.validate('/path/to/document.docx')
      #   puts result.valid? # => true
      class ZipIntegrityValidator < LayerValidator
        def layer_name
          'ZIP Integrity'
        end

        def validate(path)
          result = LayerValidationResult.new(layer_name)

          begin
            validate_zip_structure(path, result)
          rescue Zip::Error => e
            result.add_error(
              "Invalid ZIP file: #{e.message}",
              critical: true
            )
          end

          result
        end

        private

        def validate_zip_structure(path, result)
          Zip::File.open(path) do |zip_file|
            # Check ZIP is not empty
            if zip_file.entries.empty?
              result.add_error('ZIP archive is empty', critical: true)
              return
            end

            # Check required entries
            validate_required_entries(zip_file, result) if check_entries?

            # Check for corrupted entries
            validate_entry_integrity(zip_file, result) if check_corruption?
          end
        end

        def validate_required_entries(zip_file, result)
          required_entries = [
            '[Content_Types].xml',
            'word/document.xml'
          ]

          required_entries.each do |entry_name|
            next if zip_file.find_entry(entry_name)

            result.add_error(
              "Missing required file: #{entry_name}",
              critical: true
            )
          end
        end

        def validate_entry_integrity(zip_file, result)
          zip_file.entries.each do |entry|
            next if entry.directory?

            begin
              # Try to read first byte to check for corruption
              entry.get_input_stream { |io| io.read(1) }
            rescue StandardError => e
              result.add_error(
                "Corrupted entry: #{entry.name} (#{e.message})"
              )
            end
          end
        end

        def check_entries?
          layer_config[:check_entries] != false
        end

        def check_corruption?
          layer_config[:check_corruption] != false
        end

        def layer_config
          @config[:zip_integrity] || {}
        end
      end
    end
  end
end
