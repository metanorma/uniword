# frozen_string_literal: true

require_relative "base"

module Uniword
  module Validation
    module Rules
      # Validates core properties namespace declarations and xsi:type.
      #
      # DOC-105: dc/dcterms/xsi namespaces declared, xsi:type on dates
      # Validity rule: R14
      class CorePropertiesNamespaceRule < Base
        REQUIRED_NAMESPACES = {
          "dc" => "http://purl.org/dc/elements/1.1/",
          "dcterms" => "http://purl.org/dc/terms/",
          "xsi" => "http://www.w3.org/2001/XMLSchema-instance",
        }.freeze

        def code = "DOC-105"
        def validity_rule = "R14"
        def description = "Core properties must have dc/dcterms/xsi namespaces and xsi:type on dates"
        def category = :core_properties
        def severity = "error"

        def applicable?(context)
          context.part_exists?("docProps/core.xml")
        end

        def check(context)
          issues = []
          raw = context.part_raw("docProps/core.xml")
          return issues unless raw

          doc = context.part("docProps/core.xml")
          return issues unless doc

          root = doc.root
          return issues unless root

          check_namespaces(root, issues)
          check_date_types(doc, issues)

          issues
        end

        private

        def check_namespaces(root, issues)
          declared = root.namespaces.each_with_object({}) do |ns, h|
            h[ns.prefix] = ns.uri if ns.prefix
          end

          REQUIRED_NAMESPACES.each do |prefix, expected_uri|
            actual_uri = declared[prefix]
            next if actual_uri == expected_uri

            issues << issue(
              "Core properties missing xmlns:#{prefix} declaration",
              part: "docProps/core.xml",
              suggestion: "Add xmlns:#{prefix}=\"#{expected_uri}\" " \
                          "to the root element.",
            )
          end
        end

        def check_date_types(doc, issues)
          %w[created modified].each do |elem|
            node = doc.root.at_xpath("//dcterms:#{elem}",
                                     "dcterms" => REQUIRED_NAMESPACES["dcterms"])
            next unless node

            type_attr = node.attribute("type") ||
                        node.attributes.find { |a| a.name == "type" }
            next if type_attr && type_attr.value == "dcterms:W3CDTF"

            issues << issue(
              "dcterms:#{elem} missing xsi:type=\"dcterms:W3CDTF\"",
              part: "docProps/core.xml",
              suggestion: "Add xsi:type=\"dcterms:W3CDTF\" attribute.",
            )
          end
        end
      end
    end
  end
end
