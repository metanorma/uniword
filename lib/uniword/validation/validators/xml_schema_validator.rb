# frozen_string_literal: true

require "zip"
require "nokogiri"
# LayerValidator autoloaded via lib/uniword/validation.rb

module Uniword
  module Validation
    module Validators
      # Validates XML schema (well-formed XML in all parts).
      #
      # Responsibility: Validate XML structure in all parts.
      # Single Responsibility: Only validates XML well-formedness.
      #
      # This is Layer 4 validation - validates that all XML parts are
      # well-formed and parseable.
      #
      # Checks:
      # - All XML files parse without errors
      # - XML is well-formed
      # - No syntax errors
      #
      # @example Validate XML schema
      #   validator = XmlSchemaValidator.new(config)
      #   result = validator.validate('/path/to/document.docx')
      #   puts result.valid? # => true
      class XmlSchemaValidator < LayerValidator
        def layer_name
          "XML Schema"
        end

        def validate(path)
          result = LayerValidationResult.new(layer_name)

          Zip::File.open(path) do |zip|
            validate_xml_parts(zip, result)
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

        def validate_xml_parts(zip, result)
          xml_entries = zip.entries.select { |e| e.name.end_with?(".xml") }

          if xml_entries.empty?
            result.add_error(
              "No XML files found in document",
              critical: true
            )
            return
          end

          xml_entries.each do |entry|
            validate_xml_entry(entry, result)
          end
        end

        def validate_xml_entry(entry, result)
          xml_content = entry.get_input_stream.read

          if strict_parsing?
            validate_strict(entry.name, xml_content, result)
          else
            validate_lenient(entry.name, xml_content, result)
          end
        rescue StandardError => e
          result.add_error(
            "Failed to read #{entry.name}: #{e.message}"
          )
        end

        def validate_strict(filename, xml_content, result)
          doc = Nokogiri::XML(xml_content, &:strict)

          unless doc.errors.empty?
            doc.errors.each do |error|
              result.add_error(
                "XML error in #{filename}: #{error.message}"
              )
            end
          end
        rescue Nokogiri::XML::SyntaxError => e
          result.add_error(
            "Malformed XML in #{filename}: #{e.message}"
          )
        end

        def validate_lenient(filename, xml_content, result)
          doc = Nokogiri::XML(xml_content)

          if doc.errors.any?
            result.add_warning(
              "XML warnings in #{filename}: #{doc.errors.first.message}"
            )
          end
        rescue Nokogiri::XML::SyntaxError => e
          result.add_error(
            "Malformed XML in #{filename}: #{e.message}"
          )
        end

        def strict_parsing?
          layer_config[:strict_parsing] != false
        end

        def layer_config
          @config[:xml_schema] || {}
        end
      end
    end
  end
end
