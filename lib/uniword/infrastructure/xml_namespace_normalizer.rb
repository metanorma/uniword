# frozen_string_literal: true

require "nokogiri"

module Uniword
  module Infrastructure
    # XML normalization utilities for round-trip fidelity
    #
    # Ensures that serialized XML matches the expected namespace declaration format
    # by adding missing prefixed namespace declarations to root elements.
    module XmlNamespaceNormalizer
      # Prefixed namespaces that should be declared at root level in OOXML documents
      PREFIXED_NAMESPACES = {
        "http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" => "wp",
        "http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing" => "wp14"
      }.freeze

      # Normalize XML to ensure prefixed namespace declarations are at root level
      #
      # @param xml [String] XML content
      # @return [String] Normalized XML content
      def self.normalize(xml)
        doc = Nokogiri::XML(xml)
        return xml unless doc.root

        # Check if any prefixed namespaces are used but not declared at root
        root = doc.root
        root_ns = root.namespace_definitions.to_h { |ns| [ns.prefix, ns.href] }

        PREFIXED_NAMESPACES.each do |uri, expected_prefix|
          # Check if this namespace URI is used in the document
          elements_with_ns = doc.xpath("//*[namespace-uri()='#{uri}']")
          next if elements_with_ns.empty?

          # Check if the expected prefix is already declared at root
          if root_ns.key?(expected_prefix) && (root_ns[expected_prefix] == uri)
            # Check if the URI matches
            next
          end

          # Check if default namespace with this URI exists
          default_ns = root_ns.find { |k, v| k.nil? && v == uri }

          if default_ns
            # Replace default namespace with prefixed namespace
            # Find the default xmlns attribute and rename it
            root.attributes.each do |name, attr|
              next unless name == "xmlns" && attr.value == uri

              # Remove the default namespace
              root.remove_attribute("xmlns")
              # Add the prefixed namespace
              root["xmlns:#{expected_prefix}"] = uri

              # Update all elements that use this namespace to use the prefix
              update_elements_namespace(elements_with_ns, expected_prefix)
              break
            end
          else
            # Namespace is used but not declared at root - add it
            root["xmlns:#{expected_prefix}"] = uri
          end
        end

        doc.to_xml(indent: 0, save_with: Nokogiri::XML::Node::SaveOptions::AS_XML)
      end

      # Update elements to use the correct namespace prefix
      #
      # @param elements [Nokogiri::XML::NodeSet] Elements to update
      # @param prefix [String] The prefix to use
      def self.update_elements_namespace(elements, prefix)
        elements.each do |el|
          # Update the element's namespace
          ns = el.document.root.namespaces.find do |_k, v|
            v == el.namespace.href
          end
          next unless ns

          # Change namespace key from default to prefixed
          el.document.root.namespaces.delete(ns[0])
          el.document.root["xmlns:#{prefix}"] = ns[1]
        end
      end

      # Normalize namespace declarations in a ZIP content hash
      #
      # @param zip_content [Hash] File path => content mapping
      # @param target_files [Array<String>] Files to normalize
      # @return [Hash] Updated zip content
      def self.normalize_zip_content(zip_content, target_files = nil)
        result = zip_content.dup
        target_files ||= result.keys.select { |k| k.end_with?(".xml") || k.end_with?(".rels") }

        target_files.each do |path|
          next unless result[path]

          result[path] = normalize(result[path])
        end

        result
      end
    end
  end
end
