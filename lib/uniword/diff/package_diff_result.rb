# frozen_string_literal: true

require "json"

module Uniword
  module Diff
    # Value object holding a single XML change within a part.
    class XmlChange
      attr_reader :part, :category, :description

      def initialize(part:, category:, description:)
        @part = part
        @category = category
        @description = description
      end

      def to_h
        { part: @part, category: @category.to_s,
          description: @description }
      end
    end

    # Value object holding ZIP entry metadata differences.
    class ZipMetadataChange
      attr_reader :part, :differences

      # @param part [String] ZIP entry name
      # @param differences [Hash{Symbol => Array}] keys: :compression,
      #   :internal_attr, :external_attr, :timestamp, :flag_bits
      def initialize(part:, differences:)
        @part = part
        @differences = differences
      end

      def empty?
        @differences.empty?
      end

      def to_h
        { part: @part, differences: @differences }
      end
    end

    # Value object holding an OPC (Open Packaging Convention) validation issue.
    class OpcIssue
      attr_reader :part, :severity, :category, :description

      # @param part [String] ZIP entry name or package-level identifier
      # @param severity [Symbol] :error, :warning
      # @param category [Symbol] :missing_part, :missing_content_type,
      #   :orphan_content_type, :broken_relationship, :extra_namespace
      # @param description [String] human-readable explanation
      def initialize(part:, severity:, category:, description:)
        @part = part
        @severity = severity
        @category = category
        @description = description
      end

      def to_h
        { part: @part, severity: @severity.to_s,
          category: @category.to_s, description: @description }
      end
    end

    # Value object holding a changed part's metadata.
    class PartChange
      attr_reader :name, :old_size, :new_size
      attr_accessor :changes, :canon_equivalent, :canon_summary

      def initialize(name:, old_size:, new_size:, changes: [],
                     canon_equivalent: nil, canon_summary: nil)
        @name = name
        @old_size = old_size
        @new_size = new_size
        @changes = changes
        @canon_equivalent = canon_equivalent
        @canon_summary = canon_summary
      end

      def size_delta
        @new_size - @old_size
      end

      def to_h
        result = {
          name: @name,
          old_size: @old_size,
          new_size: @new_size,
          size_delta: size_delta,
        }
        result[:canon_equivalent] = @canon_equivalent unless @canon_equivalent.nil?
        result[:canon_summary] = @canon_summary if @canon_summary
        result[:xml_changes] = @changes.map(&:to_h) if @changes.any?
        result
      end
    end

    # Value object holding the result of comparing two DOCX packages.
    #
    # Contains lists of added, removed, and modified ZIP parts, plus
    # detailed XML change descriptions for modified parts, ZIP metadata
    # differences, and OPC validation issues.
    #
    # @example
    #   result = PackageDiffer.new("bad.docx", "repaired.docx").diff
    #   puts result.summary
    #   puts result.to_json
    class PackageDiffResult
      attr_reader :old_path, :new_path,
                  :added_parts, :removed_parts,
                  :modified_parts, :unchanged_parts,
                  :xml_changes, :zip_metadata_changes,
                  :opc_issues

      # Initialize a PackageDiffResult.
      #
      # @param old_path [String]
      # @param new_path [String]
      # @param added_parts [Array<String>]
      # @param removed_parts [Array<String>]
      # @param modified_parts [Array<PartChange>]
      # @param unchanged_parts [Array<String>]
      # @param xml_changes [Array<XmlChange>]
      # @param zip_metadata_changes [Array<ZipMetadataChange>]
      # @param opc_issues [Array<OpcIssue>]
      def initialize(old_path:, new_path:,
                     added_parts:, removed_parts:,
                     modified_parts:, unchanged_parts:,
                     xml_changes:, zip_metadata_changes: [],
                     opc_issues: [])
        @old_path = old_path
        @new_path = new_path
        @added_parts = added_parts
        @removed_parts = removed_parts
        @modified_parts = modified_parts
        @unchanged_parts = unchanged_parts
        @xml_changes = xml_changes
        @zip_metadata_changes = zip_metadata_changes
        @opc_issues = opc_issues
      end

      # Whether the two packages are identical.
      #
      # @return [Boolean]
      def empty?
        added_parts.empty? && removed_parts.empty? &&
          modified_parts.empty?
      end

      # Total number of changes.
      #
      # @return [Integer]
      def total_changes
        added_parts.size + removed_parts.size + modified_parts.size
      end

      # Human-readable summary.
      #
      # @return [String]
      def summary
        return "No differences found." if empty?

        parts = []
        parts << "#{added_parts.size} part(s) added" if added_parts.any?
        parts << "#{removed_parts.size} part(s) removed" if removed_parts.any?
        parts << "#{modified_parts.size} part(s) modified" if modified_parts.any?
        parts.join(", ")
      end

      # Serialize to JSON string.
      #
      # @return [String]
      def to_json(*_args)
        JSON.pretty_generate(to_h)
      end

      # Convert to plain Hash.
      #
      # @return [Hash]
      def to_h
        h = {
          old_path: @old_path,
          new_path: @new_path,
          summary: summary,
          added_parts: @added_parts,
          removed_parts: @removed_parts,
          modified_parts: @modified_parts.map(&:to_h),
          unchanged_count: @unchanged_parts.size,
          xml_changes: @xml_changes.map(&:to_h),
        }
        h[:zip_metadata_changes] = @zip_metadata_changes.map(&:to_h) if @zip_metadata_changes.any?
        h[:opc_issues] = @opc_issues.map(&:to_h) if @opc_issues.any?
        h
      end
    end
  end
end
