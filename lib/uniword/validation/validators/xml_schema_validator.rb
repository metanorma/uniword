# frozen_string_literal: true

require "zip"
require "nokogiri"
# LayerValidator autoloaded via lib/uniword/validation.rb

module Uniword
  module Validation
    module Validators
      # Validates XML schema — well-formedness and XSD schema validity.
      #
      # This is Layer 4 validation. Two modes:
      # - Well-formedness: all XML parts parse without errors
      # - XSD validation: parts validated against OOXML XSD schemas
      #
      # XSD validation uses SchemaRegistry for namespace-aware schema selection.
      # Uses Moxml for namespace detection and Nokogiri::XML::Schema for validation.
      #
      # @example Validate with XSD
      #   validator = XmlSchemaValidator.new("xml_schema" => { "xsd_validation" => true })
      #   result = validator.validate('/path/to/document.docx')
      class XmlSchemaValidator < LayerValidator
        # Markup Compatibility namespace — the mc:Ignorable attribute
        # itself lives here and is stripped during MCE preprocessing.
        MCE_NAMESPACE_URI =
          "http://schemas.openxmlformats.org/markup-compatibility/2006"

        def layer_name
          "XSD Schema"
        end

        def validate(path)
          issues = []

          Zip::File.open(path) do |zip|
            xml_entries = zip.entries.select { |e| e.name.end_with?(".xml") }

            if xml_entries.empty?
              issues << Report::ValidationIssue.new(
                severity: "error",
                code: "XSD-001",
                message: "No XML files found in document",
                suggestion: "A valid DOCX must contain at least [Content_Types].xml.",
              )
              return build_result(issues)
            end

            xml_entries.each do |entry|
              validate_entry(entry, issues)
            end

            validate_schemas(zip, xml_entries, issues) if xsd_validation?
          end

          build_result(issues)
        rescue Zip::Error => e
          issues << Report::ValidationIssue.new(
            severity: "error",
            code: "XSD-001",
            message: "Cannot open ZIP file: #{e.message}",
          )
          build_result(issues)
        end

        private

        def validate_entry(entry, issues)
          content = entry.get_input_stream.read
          Nokogiri::XML(content, &:strict)
        rescue Nokogiri::XML::SyntaxError => e
          issues << Report::ValidationIssue.new(
            severity: "error",
            code: "XSD-001",
            message: "Malformed XML in #{entry.name}: #{e.message}",
            part: entry.name,
            suggestion: "Fix the XML syntax error in this part.",
          )
        end

        def validate_schemas(_zip, xml_entries, issues)
          registry = SchemaRegistry.new

          xml_entries.each do |entry|
            schema_path = registry.primary_schema_for_part(entry.name)
            next unless schema_path

            begin
              content = entry.get_input_stream.read
              schema = registry.load_schema(schema_path)
              doc = Nokogiri::XML(content)
              preprocess_mce(doc)

              schema.validate(doc).each do |error|
                issues << Report::ValidationIssue.new(
                  severity: "error",
                  code: "XSD-002",
                  message: error.message.gsub("\n", " ").strip,
                  part: entry.name,
                  line: error.line,
                )
              end

              # Report unknown namespaces
              check_unknown_namespaces(registry, content, entry.name, issues)
            rescue ArgumentError => e
              issues << Report::ValidationIssue.new(
                severity: "warning",
                code: "XSD-003",
                message: "Schema not available for #{entry.name}: #{e.message}",
                part: entry.name,
              )
            rescue StandardError => e
              issues << Report::ValidationIssue.new(
                severity: "warning",
                code: "XSD-003",
                message: "Cannot validate #{entry.name}: #{e.message}",
                part: entry.name,
              )
            end
          end
        end

        # Strip MCE-ignorable ATTRIBUTES per the part's own mc:Ignorable
        # declaration (w14:paraId/textId and the mc:Ignorable attribute
        # itself), so XSD validation is not drowned in false errors for
        # content every real document carries.
        #
        # Extension ELEMENTS are deliberately kept: removing them changes
        # libxml2's content-model evaluation and can expose pre-existing
        # Word-vs-schema quirks (e.g. rsids placed late, tolerated via the
        # sequence's trailing xsd:any) as false baseline errors.
        # Operates in place on the parsed document; never touches the
        # packaged bytes.
        #
        # @param doc [Nokogiri::XML::Document] parsed part to clean
        # @return [void]
        def preprocess_mce(doc)
          root = doc.root
          return unless root

          ignorable = root["Ignorable"] || root["mc:Ignorable"]
          return if ignorable.nil? || ignorable.empty?

          uris = ignorable.split(/\s+/).filter_map do |prefix|
            root.namespaces["xmlns:#{prefix}"]
          end
          # The mc:Ignorable attribute itself is MCE machinery and is
          # undeclared on most root elements in the transitional XSDs.
          strip_mce_attributes(root, uris + [MCE_NAMESPACE_URI])
        end

        # Remove attributes in ignorable namespaces from every element.
        def strip_mce_attributes(doc, uris)
          doc.traverse do |node|
            next unless node.element?

            node.attribute_nodes.each do |attr|
              attr.remove if uris.include?(attr.namespace&.href)
            end
          end
        end

        def check_unknown_namespaces(registry, content, part_name, issues)
          ns_uris = registry.detect_namespaces(content)
          unknown = registry.unknown_namespaces(ns_uris)

          unknown.each do |uri|
            issues << Report::ValidationIssue.new(
              severity: "info",
              code: "XSD-003",
              message: "Unknown namespace: #{uri}",
              part: part_name,
              suggestion: "This namespace has no bundled XSD schema. " \
                          "Validation of its elements is skipped.",
            )
          end
        end

        def build_result(issues)
          result = LayerValidationResult.new(layer_name)
          issues.each do |issue|
            case issue.severity
            when "error" then result.add_error("[#{issue.code}] #{issue.message}")
            when "warning" then result.add_warning("[#{issue.code}] #{issue.message}")
            else result.add_info("[#{issue.code}] #{issue.message}")
            end
          end
          result
        end

        def xsd_validation?
          layer_config["xsd_validation"] == true
        end

        def layer_config
          @config["xml_schema"] || {}
        end
      end
    end
  end
end
