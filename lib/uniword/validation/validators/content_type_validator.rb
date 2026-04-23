# frozen_string_literal: true

require "zip"
require "nokogiri"
# LayerValidator autoloaded via lib/uniword/validation.rb

module Uniword
  module Validation
    module Validators
      # Validates content type consistency.
      #
      # Responsibility: Validate [Content_Types].xml declarations.
      # Single Responsibility: Only validates content type definitions.
      #
      # This is Layer 6 validation - validates that content types are
      # properly declared and consistent with actual file extensions.
      #
      # Checks:
      # - [Content_Types].xml is well-formed
      # - Extensions and overrides are consistent
      # - Required content types are declared
      #
      # @example Validate content types
      #   validator = ContentTypeValidator.new(config)
      #   result = validator.validate('/path/to/document.docx')
      #   puts result.valid? # => true
      class ContentTypeValidator < LayerValidator
        CONTENT_TYPES_NAMESPACE = "http://schemas.openxmlformats.org/package/2006/content-types"

        REQUIRED_CONTENT_TYPES = [
          "application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml",
          "application/vnd.openxmlformats-package.relationships+xml",
        ].freeze

        def layer_name
          "Content Types"
        end

        def validate(path)
          result = LayerValidationResult.new(layer_name)

          Zip::File.open(path) do |zip|
            validate_content_types(zip, result)
          end

          result
        rescue Zip::Error => e
          result.add_error(
            "Cannot open ZIP file: #{e.message}",
            critical: true,
          )
          result
        end

        private

        def validate_content_types(zip, result)
          entry = zip.find_entry("[Content_Types].xml")

          unless entry
            result.add_error(
              "Missing [Content_Types].xml",
              critical: true,
            )
            return
          end

          validate_content_types_file(zip, entry, result)
        end

        def validate_content_types_file(zip, entry, result)
          xml_content = entry.get_input_stream.read
          doc = Nokogiri::XML(xml_content)

          # Check for required content types
          validate_required_types(doc, result) if check_consistency?

          # Validate extensions match actual files
          if validate_extensions?
            validate_extension_consistency(zip, doc,
                                           result)
          end
        rescue Nokogiri::XML::SyntaxError => e
          result.add_error(
            "Malformed [Content_Types].xml: #{e.message}",
            critical: true,
          )
        rescue StandardError => e
          result.add_error(
            "Failed to validate content types: #{e.message}",
          )
        end

        def validate_required_types(doc, result)
          declared_types = extract_declared_types(doc)

          REQUIRED_CONTENT_TYPES.each do |required_type|
            next if declared_types.include?(required_type)

            result.add_warning(
              "Required content type not declared: #{required_type}",
            )
          end
        end

        def extract_declared_types(doc)
          types = []

          # From Default elements
          doc.xpath("//xmlns:Default",
                    "xmlns" => CONTENT_TYPES_NAMESPACE).each do |default|
            types << default["ContentType"] if default["ContentType"]
          end

          # From Override elements
          doc.xpath("//xmlns:Override",
                    "xmlns" => CONTENT_TYPES_NAMESPACE).each do |override|
            types << override["ContentType"] if override["ContentType"]
          end

          types
        end

        def validate_extension_consistency(zip, doc, result)
          # Get declared extensions
          extensions = {}
          doc.xpath("//xmlns:Default",
                    "xmlns" => CONTENT_TYPES_NAMESPACE).each do |default|
            ext = default["Extension"]
            content_type = default["ContentType"]
            extensions[ext] = content_type if ext && content_type
          end

          # Check if files with declared extensions exist
          zip.entries.each do |entry|
            next if entry.directory?

            ext = File.extname(entry.name)[1..] # Remove leading dot
            next unless ext

            if extensions.key?(ext)
              # Expected extension found
            else
              result.add_info(
                "File #{entry.name} has undeclared extension: .#{ext}",
              )
            end
          end
        end

        def check_consistency?
          layer_config[:check_consistency] != false
        end

        def validate_extensions?
          layer_config[:validate_extensions] != false
        end

        def layer_config
          @config[:content_types] || {}
        end
      end
    end
  end
end
