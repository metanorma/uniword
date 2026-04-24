# frozen_string_literal: true

require "zip"
require "nokogiri"
require "canon"
require_relative "package_diff_result"

module Uniword
  module Diff
    # Compares two DOCX files at the ZIP/XML/OPC structural level.
    #
    # Detects differences in:
    # - ZIP entries (added/removed parts)
    # - ZIP entry metadata (compression, text/binary flag, timestamps)
    # - XML content (semantic equivalence via Canon, element structure)
    # - OPC validation (content types, relationships, required parts)
    #
    # Unlike DocumentDiffer (which compares loaded DocumentRoot models),
    # PackageDiffer works on raw DOCX ZIP contents, detecting what Word
    # or other applications changed during repair.
    #
    # @example Basic comparison
    #   differ = PackageDiffer.new("bad.docx", "repaired.docx")
    #   result = differ.diff
    #   puts result.summary
    #
    # @example With Canon semantic comparison
    #   result = PackageDiffer.new("bad.docx", "repaired.docx",
    #     canon: true).diff
    #   result.modified_parts.each do |p|
    #     puts "#{p.name}: canon_equivalent=#{p.canon_equivalent}"
    #   end
    class PackageDiffer
      # Required parts for a valid OOXML DOCX package.
      REQUIRED_PARTS = %w[
        [Content_Types].xml
        _rels/.rels
        word/document.xml
      ].freeze

      # Standard DOCX parts and their expected content types.
      STANDARD_CONTENT_TYPES = {
        "word/document.xml" => "application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml",
        "word/styles.xml" => "application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml",
        "word/settings.xml" => "application/vnd.openxmlformats-officedocument.wordprocessingml.settings+xml",
        "word/fontTable.xml" => "application/vnd.openxmlformats-officedocument.wordprocessingml.fontTable+xml",
        "word/webSettings.xml" => "application/vnd.openxmlformats-officedocument.wordprocessingml.webSettings+xml",
        "word/theme/theme1.xml" => "application/vnd.openxmlformats-officedocument.theme+xml",
        "docProps/core.xml" => "application/vnd.openxmlformats-package.core-properties+xml",
        "docProps/app.xml" => "application/vnd.openxmlformats-officedocument.extended-properties+xml",
      }.freeze

      # Initialize with two DOCX file paths.
      #
      # @param old_path [String] Path to original DOCX
      # @param new_path [String] Path to modified/repaired DOCX
      # @param canon [Boolean] Whether to use Canon for semantic XML comparison
      # @param canon_profile [Symbol] Canon match profile to use
      def initialize(old_path, new_path, canon: false, canon_profile: :spec_friendly)
        @old_path = old_path
        @new_path = new_path
        @canon = canon
        @canon_profile = canon_profile
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
          metadata_diff = diff_zip_metadata(old_zip, new_zip)
          opc = validate_opc(old_zip, new_zip)
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
          xml_changes: content_diff,
          zip_metadata_changes: metadata_diff,
          opc_issues: opc,
        )
      end

      private

      # Compare ZIP entry lists to find added/removed/modified parts.
      #
      # @return [Hash] Lists of added, removed, modified, unchanged parts
      def diff_parts(old_zip, new_zip)
        old_entries = old_zip.entries.reject(&:directory?)
          .to_set(&:name)
        new_entries = new_zip.entries.reject(&:directory?)
          .to_set(&:name)

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
              changes: [],
            )
          end
        end

        { added: added, removed: removed, modified: modified,
          unchanged: unchanged }
      end

      # Compare XML content for modified parts.
      # Uses Canon for semantic comparison when enabled.
      #
      # @return [Array<XmlChange>]
      def diff_xml_content(old_zip, new_zip, part_diff)
        changes = []

        part_diff[:modified].each do |part_change|
          name = part_change.name
          next unless name.end_with?(".xml")

          old_xml = old_zip.read(name)
          new_xml = new_zip.read(name)

          # Canon semantic comparison
          if @canon
            check_canon_equivalence(part_change, old_xml, new_xml)
          end

          # Structural comparison (always run)
          part_changes = compare_xml(name, old_xml, new_xml)
          part_change.changes = part_changes
          changes.concat(part_changes)
        end

        changes
      end

      # Check semantic equivalence using Canon.
      #
      # @param part_change [PartChange] the part to check
      # @param old_xml [String]
      # @param new_xml [String]
      def check_canon_equivalence(part_change, old_xml, new_xml)
        result = Canon::Comparison.equivalent?(
          old_xml, new_xml,
          format: :xml,
          profile: @canon_profile,
          verbose: true,
        )
        part_change.canon_equivalent = result.equivalent?
        return if result.equivalent?

        diffs = result.normative_differences
        if diffs.any?
          summary = diffs.first(3).map do |d|
            "#{d.dimension}: #{d.path} — #{d.reason}"
          end
          part_change.canon_summary = summary.join("; ")
          part_change.canon_summary += " (#{diffs.size} differences total)" if diffs.size > 3
        else
          part_change.canon_summary = "No normative differences found"
        end
      rescue StandardError => e
        part_change.canon_equivalent = false
        part_change.canon_summary = "Canon error: #{e.message}"
      end

      # Compare two XML strings and return structural changes.
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
          diff_namespaces(part_name, old_doc, new_doc),
        )

        # Compare root element attributes
        changes.concat(
          diff_root_attributes(part_name, old_doc, new_doc),
        )

        # Compare element counts
        changes.concat(
          diff_element_counts(part_name, old_doc, new_doc),
        )

        changes
      rescue Nokogiri::XML::SyntaxError
        changes
      end

      # Compare ZIP entry metadata between two packages.
      #
      # @param old_zip [Zip::File]
      # @param new_zip [Zip::File]
      # @return [Array<ZipMetadataChange>]
      def diff_zip_metadata(old_zip, new_zip)
        old_entries = entry_map(old_zip)
        new_entries = entry_map(new_zip)
        common = old_entries.keys & new_entries.keys

        common.filter_map do |name|
          old_e = old_entries[name]
          new_e = new_entries[name]
          diffs = {}

          if old_e.compression_method != new_e.compression_method
            diffs[:compression] = [compression_name(old_e.compression_method),
                                   compression_name(new_e.compression_method)]
          end

          old_text = old_e.internal_file_attributes & 1 != 0
          new_text = new_e.internal_file_attributes & 1 != 0
          if old_text != new_text
            diffs[:internal_attr] = [old_text ? "text" : "binary",
                                     new_text ? "text" : "binary"]
          end

          if old_e.time != new_e.time
            diffs[:timestamp] = [old_e.time.to_s, new_e.time.to_s]
          end

          next if diffs.empty?

          ZipMetadataChange.new(part: name, differences: diffs)
        end
      end

      # Validate OPC structure for both packages.
      #
      # @param old_zip [Zip::File]
      # @param new_zip [Zip::File]
      # @return [Array<OpcIssue>]
      def validate_opc(old_zip, new_zip)
        issues = []
        [%i[old old_zip], %i[new new_zip]].each do |label, zip_var|
          zip = binding.local_variable_get(zip_var)
          issues.concat(validate_opc_for(zip, label))
        end
        issues
      end

      # Validate OPC structure for a single package.
      #
      # @param zip [Zip::File]
      # @param label [Symbol] :old or :new
      # @return [Array<OpcIssue>]
      def validate_opc_for(zip, label)
        issues = []
        part_names = zip.entries.reject(&:directory?).map(&:name).to_set

        # Check required parts
        REQUIRED_PARTS.each do |req|
          next if part_names.include?(req)

          issues << OpcIssue.new(
            part: req,
            severity: :error,
            category: :missing_part,
            description: "Missing required part '#{req}' in #{label} package",
          )
        end

        # Parse content types
        ct_overrides = parse_content_types(zip)
        if ct_overrides.nil?
          issues << OpcIssue.new(
            part: "[Content_Types].xml",
            severity: :error,
            category: :missing_content_type,
            description: "[Content_Types].xml missing or unparseable in #{label} package",
          )
          return issues
        end

        # Check: every XML part should have a content type
        part_names.each do |part|
          next if part == "[Content_Types].xml"
          next if part.end_with?(".rels")
          next if ct_overrides.key?("/#{part}")

          # Only warn for known standard parts
          next unless STANDARD_CONTENT_TYPES.key?(part)

          issues << OpcIssue.new(
            part: part,
            severity: :warning,
            category: :missing_content_type,
            description: "No content type override for '#{part}' in #{label} package",
          )
        end

        # Check: content type overrides should point to existing parts
        ct_overrides.each_key do |part_name|
          # Strip leading /
          stripped = part_name.start_with?("/") ? part_name[1..] : part_name
          next if part_names.include?(stripped)

          issues << OpcIssue.new(
            part: stripped,
            severity: :warning,
            category: :orphan_content_type,
            description: "Content type entry for '#{stripped}' but part not found in #{label} package",
          )
        end

        # Check relationships point to existing parts
        issues.concat(validate_relationships(zip, part_names, label))

        issues
      end

      # Validate that relationships point to existing parts.
      #
      # @param zip [Zip::File]
      # @param part_names [Set<String>]
      # @param label [Symbol]
      # @return [Array<OpcIssue>]
      def validate_relationships(zip, part_names, label)
        issues = []

        # Check package-level relationships
        begin
          rels_xml = zip.read("_rels/.rels")
        rescue StandardError
          return issues
        end

        doc = Nokogiri::XML(rels_xml)
        doc.xpath("//xmlns:Relationship").each do |rel|
          target = rel["Target"]&.sub(%r{^/}, "")
          next unless target
          next if part_names.include?(target)

          issues << OpcIssue.new(
            part: target,
            severity: :warning,
            category: :broken_relationship,
            description: "Relationship #{rel['Id']} targets '#{target}' but part not found in #{label} package",
          )
        end

        issues
      rescue Nokogiri::XML::SyntaxError
        issues
      end

      # Parse [Content_Types].xml into a hash of PartName => ContentType.
      #
      # @param zip [Zip::File]
      # @return [Hash{String => String}, nil]
      def parse_content_types(zip)
        ct_xml = zip.read("[Content_Types].xml")
        doc = Nokogiri::XML(ct_xml)
        overrides = {}
        doc.xpath("//xmlns:Override").each do |node|
          overrides[node["PartName"]] = node["ContentType"]
        end
        overrides
      rescue StandardError
        nil
      end

      # --- Legacy structural comparison methods (kept for backward compat) ---

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
                         "#{added_ns.map do |p|
                           p.empty? ? 'xmlns' : "xmlns:#{p}"
                         end
                           .join(', ')}",
          )
        end

        if removed_ns.any?
          changes << XmlChange.new(
            part: part_name,
            category: :namespace,
            description: "Removed #{removed_ns.size} namespace(s): " \
                         "#{removed_ns.map do |p|
                           p.empty? ? 'xmlns' : "xmlns:#{p}"
                         end
                           .join(', ')}",
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
          .reject { |k| old_attrs[k] == new_attrs[k] }

        if added_attrs.any?
          changes << XmlChange.new(
            part: part_name,
            category: :attribute,
            description: "Added #{added_attrs.size} attribute(s) on " \
                         "<#{old_doc.root.name}>: #{added_attrs.join(', ')}",
          )
        end

        if removed_attrs.any?
          changes << XmlChange.new(
            part: part_name,
            category: :attribute,
            description: "Removed #{removed_attrs.size} attribute(s) on " \
                         "<#{old_doc.root.name}>: #{removed_attrs.join(', ')}",
          )
        end

        changed_attrs.each do |attr|
          changes << XmlChange.new(
            part: part_name,
            category: :attribute,
            description: "Changed #{attr} on <#{old_doc.root.name}>: " \
                         "'#{old_attrs[attr]}' -> '#{new_attrs[attr]}'",
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
            description: "#{element}: #{old_count} -> #{new_count}",
          )
        end

        changes
      end

      # --- Utility methods ---

      # Build a hash of entry name -> Zip::Entry for non-directory entries.
      #
      # @param zip [Zip::File]
      # @return [Hash{String => Zip::Entry}]
      def entry_map(zip)
        zip.entries.reject(&:directory?).to_h { |e| [e.name, e] }
      end

      # Human-readable compression method name.
      #
      # @param method [Integer]
      # @return [String]
      def compression_name(method)
        case method
        when 0 then "stored"
        when 8 then "deflated"
        else "unknown(#{method})"
        end
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
