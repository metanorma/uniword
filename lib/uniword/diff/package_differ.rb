# frozen_string_literal: true

require "zip"
require "nokogiri"
require_relative "package_diff_result"

module Uniword
  module Diff
    # Compares two DOCX files at the ZIP/XML structural level.
    #
    # Detects differences in:
    # - ZIP entries (added/removed parts)
    # - XML content (element structure, attributes, namespaces)
    # - Content size differences
    #
    # Unlike DocumentDiffer (which compares loaded DocumentRoot models),
    # PackageDiffer works on raw DOCX ZIP contents, detecting what Word
    # or other applications changed during repair.
    #
    # @example
    #   differ = PackageDiffer.new("bad.docx", "repaired.docx")
    #   result = differ.diff
    #   puts result.summary
    class PackageDiffer
      # Initialize with two DOCX file paths.
      #
      # @param old_path [String] Path to original DOCX
      # @param new_path [String] Path to modified/repaired DOCX
      def initialize(old_path, new_path)
        @old_path = old_path
        @new_path = new_path
      end

      # Perform structural diff and return a PackageDiffResult.
      #
      # @return [PackageDiffResult]
      def diff
        old_zip = Zip::File.open(@old_path)
        new_zip = Zip::File.open(@new_path)

        begin
          part_diff = diff_parts(old_zip, new_zip)
          content_diff = diff_xml_content(old_zip, new_zip, part_diff)
        ensure
          old_zip.close
          new_zip.close
        end

        PackageDiffResult.new(
          old_path: @old_path,
          new_path: @new_path,
          added_parts: part_diff[:added],
          removed_parts: part_diff[:removed],
          modified_parts: part_diff[:modified],
          unchanged_parts: part_diff[:unchanged],
          xml_changes: content_diff
        )
      end

      private

      # Compare ZIP entry lists to find added/removed/modified parts.
      #
      # @return [Hash] Lists of added, removed, modified, unchanged parts
      def diff_parts(old_zip, new_zip)
        old_entries = old_zip.entries.reject(&:directory?)
                                    .map(&:name).to_set
        new_entries = new_zip.entries.reject(&:directory?)
                                    .map(&:name).to_set

        added = (new_entries - old_entries).sort
        removed = (old_entries - new_entries).sort
        common = (old_entries & new_entries).sort

        modified = []
        unchanged = []

        common.each do |name|
          old_size = old_zip.find_entry(name).size
          new_size = new_zip.find_entry(name).size
          old_content = old_zip.read(name)
          new_content = new_zip.read(name)

          if old_content == new_content
            unchanged << name
          else
            modified << PartChange.new(
              name: name,
              old_size: old_size,
              new_size: new_size,
              changes: []
            )
          end
        end

        { added: added, removed: removed, modified: modified,
          unchanged: unchanged }
      end

      # Compare XML content for modified parts.
      #
      # @return [Array<XmlChange>]
      def diff_xml_content(old_zip, new_zip, part_diff)
        changes = []

        part_diff[:modified].each do |part_change|
          name = part_change.name
          next unless name.end_with?(".xml")

          old_xml = old_zip.read(name)
          new_xml = new_zip.read(name)

          part_changes = compare_xml(name, old_xml, new_xml)
          part_change.changes = part_changes
          changes.concat(part_changes)
        end

        changes
      end

      # Compare two XML strings and return changes.
      #
      # @param part_name [String] ZIP part name
      # @param old_xml [String] Original XML content
      # @param new_xml [String] Modified XML content
      # @return [Array<XmlChange>]
      def compare_xml(part_name, old_xml, new_xml)
        changes = []

        old_doc = Nokogiri::XML(old_xml)
        new_doc = Nokogiri::XML(new_xml)

        # Compare namespace declarations
        changes.concat(
          diff_namespaces(part_name, old_doc, new_doc)
        )

        # Compare root element attributes
        changes.concat(
          diff_root_attributes(part_name, old_doc, new_doc)
        )

        # Compare element counts
        changes.concat(
          diff_element_counts(part_name, old_doc, new_doc)
        )

        changes
      rescue Nokogiri::XML::SyntaxError
        changes
      end

      # Compare namespace declarations between two XML documents.
      #
      # @return [Array<XmlChange>]
      def diff_namespaces(part_name, old_doc, new_doc)
        changes = []

        old_ns = namespace_hash(old_doc.root)
        new_ns = namespace_hash(new_doc.root)

        added_ns = new_ns.keys - old_ns.keys
        removed_ns = old_ns.keys - new_ns.keys

        if added_ns.any?
          changes << XmlChange.new(
            part: part_name,
            category: :namespace,
            description: "Added #{added_ns.size} namespace(s): " \
                         "#{added_ns.map { |p| p.empty? ? 'xmlns' : "xmlns:#{p}" }
                                   .join(', ')}"
          )
        end

        if removed_ns.any?
          changes << XmlChange.new(
            part: part_name,
            category: :namespace,
            description: "Removed #{removed_ns.size} namespace(s): " \
                         "#{removed_ns.map { |p| p.empty? ? 'xmlns' : "xmlns:#{p}" }
                                     .join(', ')}"
          )
        end

        changes
      end

      # Compare root element attributes.
      #
      # @return [Array<XmlChange>]
      def diff_root_attributes(part_name, old_doc, new_doc)
        changes = []

        old_attrs = attribute_hash(old_doc.root)
        new_attrs = attribute_hash(new_doc.root)

        added_attrs = new_attrs.keys - old_attrs.keys
        removed_attrs = old_attrs.keys - new_attrs.keys
        changed_attrs = (old_attrs.keys & new_attrs.keys)
                          .select { |k| old_attrs[k] != new_attrs[k] }

        if added_attrs.any?
          changes << XmlChange.new(
            part: part_name,
            category: :attribute,
            description: "Added #{added_attrs.size} attribute(s) on " \
                         "<#{old_doc.root.name}>: #{added_attrs.join(', ')}"
          )
        end

        if removed_attrs.any?
          changes << XmlChange.new(
            part: part_name,
            category: :attribute,
            description: "Removed #{removed_attrs.size} attribute(s) on " \
                         "<#{old_doc.root.name}>: #{removed_attrs.join(', ')}"
          )
        end

        changed_attrs.each do |attr|
          changes << XmlChange.new(
            part: part_name,
            category: :attribute,
            description: "Changed #{attr} on <#{old_doc.root.name}>: " \
                         "'#{old_attrs[attr]}' -> '#{new_attrs[attr]}'"
          )
        end

        changes
      end

      # Compare element counts between two XML documents.
      #
      # @return [Array<XmlChange>]
      def diff_element_counts(part_name, old_doc, new_doc)
        changes = []

        old_counts = element_counts(old_doc)
        new_counts = element_counts(new_doc)

        all_elements = (old_counts.keys | new_counts.keys).sort

        all_elements.each do |element|
          old_count = old_counts[element] || 0
          new_count = new_counts[element] || 0
          next if old_count == new_count

          changes << XmlChange.new(
            part: part_name,
            category: :element_count,
            description: "#{element}: #{old_count} -> #{new_count}"
          )
        end

        changes
      end

      # Extract namespace prefix-to-URI mapping from an element.
      #
      # @param element [Nokogiri::XML::Element]
      # @return [Hash{String => String}]
      def namespace_hash(element)
        return {} unless element

        result = {}
        element.namespace_definitions.each do |ns|
          prefix = ns.prefix || ""
          result[prefix] = ns.href
        end
        result
      end

      # Extract attribute name-to-value mapping from an element.
      #
      # @param element [Nokogiri::XML::Element]
      # @return [Hash{String => String}]
      def attribute_hash(element)
        return {} unless element

        result = {}
        element.attributes.each do |name, attr|
          key = attr.namespace ? "#{attr.namespace.prefix}:#{name}" : name
          result[key] = attr.value
        end
        result
      end

      # Count elements by qualified name.
      #
      # @param doc [Nokogiri::XML::Document]
      # @return [Hash{String => Integer}]
      def element_counts(doc)
        counts = Hash.new(0)
        doc.traverse do |node|
          next unless node.element?

          prefix = node.namespace&.prefix
          name = prefix ? "#{prefix}:#{node.name}" : node.name
          counts[name] += 1
        end
        counts
      end
    end
  end
end
