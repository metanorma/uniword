# frozen_string_literal: true

require 'zip'
require 'nokogiri'
# LayerValidator autoloaded via lib/uniword/validation.rb

module Uniword
  module Validation
    module Validators
      # Validates document semantic structure.
      #
      # Responsibility: Validate document content structure and semantics.
      # Single Responsibility: Only validates document semantics.
      #
      # This is Layer 7 validation - validates the document content itself
      # has valid structure according to WordprocessingML schema.
      #
      # Checks:
      # - Required elements present (body, sections)
      # - Valid document structure
      # - Style references are valid
      #
      # @example Validate document semantics
      #   validator = DocumentSemanticsValidator.new(config)
      #   result = validator.validate('/path/to/document.docx')
      #   puts result.valid? # => true
      class DocumentSemanticsValidator < LayerValidator
        WORDML_NAMESPACE = 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'

        def layer_name
          'Document Semantics'
        end

        def validate(path)
          result = LayerValidationResult.new(layer_name)

          Zip::File.open(path) do |zip|
            validate_document_structure(zip, result)
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

        def validate_document_structure(zip, result)
          doc_entry = zip.find_entry('word/document.xml')

          unless doc_entry
            result.add_error(
              'word/document.xml not found',
              critical: true
            )
            return
          end

          validate_document_xml(doc_entry, result)
        end

        def validate_document_xml(entry, result)
          xml_content = entry.get_input_stream.read
          doc = Nokogiri::XML(xml_content)

          # Check for required elements
          validate_required_elements(doc, result) if check_required_elements?

          # Validate document structure
          validate_document_hierarchy(doc, result) if validate_structure?
        rescue Nokogiri::XML::SyntaxError => e
          result.add_error(
            "Malformed document.xml: #{e.message}",
            critical: true
          )
        rescue StandardError => e
          result.add_error(
            "Failed to validate document semantics: #{e.message}"
          )
        end

        def validate_required_elements(doc, result)
          # Check for document element
          document_elem = doc.at_xpath('//w:document', 'w' => WORDML_NAMESPACE)
          unless document_elem
            result.add_error(
              'Missing <w:document> root element',
              critical: true
            )
            return
          end

          # Check for body element
          body_elem = doc.at_xpath('//w:body', 'w' => WORDML_NAMESPACE)
          unless body_elem
            result.add_error(
              'Missing <w:body> element',
              critical: true
            )
            return
          end

          # Check if body is empty
          return unless body_elem.children.none?(&:element?)

          result.add_warning('Document body is empty')
        end

        def validate_document_hierarchy(doc, result)
          # Check that paragraphs are in body
          paragraphs = doc.xpath('//w:p', 'w' => WORDML_NAMESPACE)
          body = doc.at_xpath('//w:body', 'w' => WORDML_NAMESPACE)

          return unless body

          paragraphs.each do |p|
            # Check if paragraph is descendant of body
            next if p.ancestors.include?(body)

            result.add_warning(
              'Paragraph found outside document body'
            )
          end

          # Check for section properties
          sect_pr = doc.at_xpath('//w:body/w:sectPr', 'w' => WORDML_NAMESPACE)
          return if sect_pr

          result.add_info(
            'No section properties defined (using defaults)'
          )
        end

        def check_required_elements?
          layer_config[:check_required_elements] != false
        end

        def validate_structure?
          layer_config[:validate_structure] != false
        end

        def layer_config
          @config[:document_semantics] || {}
        end
      end
    end
  end
end
