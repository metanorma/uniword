# frozen_string_literal: true

require "zip"
# LayerValidator autoloaded via lib/uniword/validation.rb

module Uniword
  module Validation
    module Validators
      # Validates OOXML part structure (required/optional parts).
      #
      # Responsibility: Validate OOXML parts exist per ISO/IEC 29500.
      # Single Responsibility: Only validates part existence.
      #
      # This is Layer 3 validation - validates that all required OOXML
      # parts are present in the document package.
      #
      # Checks:
      # - Required parts exist (Content Types, document, relationships)
      # - Optional but common parts (styles, numbering)
      #
      # @example Validate OOXML parts
      #   validator = OoxmlPartValidator.new(config)
      #   result = validator.validate('/path/to/document.docx')
      #   puts result.valid? # => true
      class OoxmlPartValidator < LayerValidator
        # Required parts per ISO/IEC 29500
        REQUIRED_PARTS = {
          "[Content_Types].xml" => "Content Types definition",
          "word/document.xml" => "Main document content",
          "_rels/.rels" => "Package relationships"
        }.freeze

        # Optional but commonly used parts
        OPTIONAL_PARTS = {
          "word/styles.xml" => "Styles definition",
          "word/numbering.xml" => "Numbering definition",
          "word/_rels/document.xml.rels" => "Document relationships",
          "word/settings.xml" => "Document settings",
          "word/fontTable.xml" => "Font table",
          "word/theme/theme1.xml" => "Theme definition"
        }.freeze

        def layer_name
          "OOXML Parts"
        end

        def validate(path)
          result = LayerValidationResult.new(layer_name)

          Zip::File.open(path) do |zip|
            validate_required_parts(zip, result)
            validate_optional_parts(zip, result) if warn_missing_optional?
          end

          result
        rescue Zip::Error => e
          result.add_error(
            "Cannot open ZIP file: #{e.message}",
            critical: true
          )
          result
        end

        private

        def validate_required_parts(zip, result)
          return unless require_content_types? ||
                        require_document? ||
                        require_relationships?

          REQUIRED_PARTS.each do |part_name, description|
            next unless should_check_part?(part_name)

            next if zip.find_entry(part_name)

            result.add_error(
              "Missing #{description}: #{part_name}",
              critical: true
            )
          end
        end

        def validate_optional_parts(zip, result)
          OPTIONAL_PARTS.each do |part_name, description|
            next if zip.find_entry(part_name)

            result.add_info(
              "Missing #{description}: #{part_name} (optional)"
            )
          end
        end

        def should_check_part?(part_name)
          case part_name
          when "[Content_Types].xml"
            require_content_types?
          when "word/document.xml"
            require_document?
          when "_rels/.rels"
            require_relationships?
          else
            true
          end
        end

        def require_content_types?
          layer_config[:require_content_types] != false
        end

        def require_document?
          layer_config[:require_document] != false
        end

        def require_relationships?
          layer_config[:require_relationships] != false
        end

        def warn_missing_optional?
          layer_config[:warn_missing_optional] != false
        end

        def layer_config
          @config[:ooxml_parts] || {}
        end
      end
    end
  end
end
